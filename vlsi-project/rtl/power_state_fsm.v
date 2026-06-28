// =============================================================================
// File        : power_state_fsm.v
// Module      : power_state_fsm
// Description : Main power state controller FSM. Mediates between the
//               hysteresis predictor's sleep_req and actual power mode
//               transitions, enforcing minimum wake-up latency delays before
//               resuming operation from each sleep mode.
//
//               States:
//                 ON          : Normal operation
//                 TO_LS       : Transitioning into Light Sleep (1-cycle ramp)
//                 LIGHT_SLEEP : State-retentive low-power mode
//                 TO_DS       : Transitioning into Deep Sleep (1-cycle ramp)
//                 DEEP_SLEEP  : Non-state-retentive deep low-power mode
//                 WAKEUP_LS   : Waking up from Light Sleep (WU_LS_CYCLES delay)
//                 WAKEUP_DS   : Waking up from Deep Sleep (WU_DS_CYCLES delay)
//
//               Wake-up latency values from p4 (Agarwal/IBM):
//                 Light Sleep : 3 cycles  (state retentive)
//                 Deep Sleep  : 8 cycles  (must re-initialize state)
//
// =============================================================================

module power_state_fsm #(
    parameter WU_LS_CYCLES = 4'd3,   // Wake-up latency from Light Sleep
    parameter WU_DS_CYCLES = 4'd8    // Wake-up latency from Deep Sleep
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  sleep_req,    // From hysteresis_predictor
    input  wire        wakeup_req,   // External wake-up request (e.g., interrupt)
    output reg  [2:0]  fsm_state,    // Full internal state (for debug/coverage)
    output reg  [1:0]  power_mode,   // 2'b00=ON, 2'b01=LS, 2'b10=DS
    output reg         iso_en,       // Isolation enable: clamp outputs in sleep
    output reg         sleep_n,      // Active-low sleep to power domain
    output reg         wakeup_done,  // Pulsed 1 cycle when wake-up completes
    output reg  [3:0]  wakeup_timer  // Remaining wake-up cycles (for monitoring)
);

    // -------------------------------------------------------------------------
    // FSM state encoding
    // -------------------------------------------------------------------------
    localparam S_ON         = 3'd0;
    localparam S_TO_LS      = 3'd1;
    localparam S_LIGHT_SLEEP= 3'd2;
    localparam S_TO_DS      = 3'd3;
    localparam S_DEEP_SLEEP = 3'd4;
    localparam S_WAKEUP_LS  = 3'd5;
    localparam S_WAKEUP_DS  = 3'd6;

    // Power mode encoding
    localparam PM_ON = 2'b00;
    localparam PM_LS = 2'b01;
    localparam PM_DS = 2'b10;

    // sleep_req encoding (matches hysteresis_predictor)
    localparam REQ_ON = 2'b00;
    localparam REQ_LS = 2'b01;
    localparam REQ_DS = 2'b10;

    // -------------------------------------------------------------------------
    // Next-state and output logic
    // -------------------------------------------------------------------------
    reg [2:0] next_state;
    reg [3:0] next_timer;

    // Combinational next-state
    always @(*) begin
        next_state  = fsm_state;
        next_timer  = wakeup_timer;

        case (fsm_state)

            // ------------------------------------------------------------------
            // ON: evaluate predictor request
            // ------------------------------------------------------------------
            S_ON: begin
                if (sleep_req == REQ_LS)
                    next_state = S_TO_LS;
                else if (sleep_req == REQ_DS)
                    next_state = S_TO_DS;
                else
                    next_state = S_ON;
            end

            // ------------------------------------------------------------------
            // TO_LS: one ramp-in cycle — asserts iso_en before sleep
            // ------------------------------------------------------------------
            S_TO_LS: begin
                next_state = S_LIGHT_SLEEP;
            end

            // ------------------------------------------------------------------
            // LIGHT_SLEEP: wait for predictor to request wake-up
            // ------------------------------------------------------------------
            S_LIGHT_SLEEP: begin
                if (wakeup_req || (sleep_req == REQ_ON))
                    next_state = S_WAKEUP_LS;
                else if (sleep_req == REQ_DS)
                    next_state = S_TO_DS;
                else
                    next_state = S_LIGHT_SLEEP;
            end

            // ------------------------------------------------------------------
            // TO_DS: one ramp-in cycle into deep sleep
            // ------------------------------------------------------------------
            S_TO_DS: begin
                next_state = S_DEEP_SLEEP;
            end

            // ------------------------------------------------------------------
            // DEEP_SLEEP: wait for wake-up request
            // ------------------------------------------------------------------
            S_DEEP_SLEEP: begin
                if (wakeup_req || (sleep_req == REQ_ON))
                    next_state = S_WAKEUP_DS;
                else
                    next_state = S_DEEP_SLEEP;
            end

            // ------------------------------------------------------------------
            // WAKEUP_LS: count WU_LS_CYCLES cycles before asserting ON
            // ------------------------------------------------------------------
            S_WAKEUP_LS: begin
                if (wakeup_timer == 4'd0) begin
                    next_state = S_ON;
                end else begin
                    next_state = S_WAKEUP_LS;
                    next_timer = wakeup_timer - 4'd1;
                end
            end

            // ------------------------------------------------------------------
            // WAKEUP_DS: count WU_DS_CYCLES cycles before asserting ON
            // ------------------------------------------------------------------
            S_WAKEUP_DS: begin
                if (wakeup_timer == 4'd0) begin
                    next_state = S_ON;
                end else begin
                    next_state = S_WAKEUP_DS;
                    next_timer = wakeup_timer - 4'd1;
                end
            end

            default: next_state = S_ON;
        endcase
    end

    // -------------------------------------------------------------------------
    // Sequential state register with output generation
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            fsm_state    <= S_ON;
            power_mode   <= PM_ON;
            iso_en       <= 1'b0;
            sleep_n      <= 1'b1;   // active-low: 1 = domain powered
            wakeup_done  <= 1'b0;
            wakeup_timer <= 4'd0;
        end else begin
            fsm_state    <= next_state;
            wakeup_done  <= 1'b0;   // default: not pulsing

            case (next_state)
                S_ON: begin
                    power_mode   <= PM_ON;
                    iso_en       <= 1'b0;
                    sleep_n      <= 1'b1;
                    wakeup_timer <= 4'd0;
                    // Pulse wakeup_done if we just finished a wake-up
                    if (fsm_state == S_WAKEUP_LS || fsm_state == S_WAKEUP_DS)
                        wakeup_done <= 1'b1;
                end

                S_TO_LS: begin
                    power_mode   <= PM_ON;   // Still ON during ramp
                    iso_en       <= 1'b1;    // Assert isolation first
                    sleep_n      <= 1'b1;
                    wakeup_timer <= 4'd0;
                end

                S_LIGHT_SLEEP: begin
                    power_mode   <= PM_LS;
                    iso_en       <= 1'b1;
                    sleep_n      <= 1'b0;   // Sleep asserted (partial)
                    wakeup_timer <= 4'd0;
                end

                S_TO_DS: begin
                    power_mode   <= PM_LS;  // Coming from LS during ramp
                    iso_en       <= 1'b1;
                    sleep_n      <= 1'b0;
                    wakeup_timer <= 4'd0;
                end

                S_DEEP_SLEEP: begin
                    power_mode   <= PM_DS;
                    iso_en       <= 1'b1;
                    sleep_n      <= 1'b0;   // Full sleep
                    wakeup_timer <= 4'd0;
                end

                S_WAKEUP_LS: begin
                    power_mode   <= PM_LS;
                    iso_en       <= 1'b1;   // Keep isolated during wake-up
                    sleep_n      <= 1'b1;   // Power domain re-enabled
                    // Load timer on entry from LIGHT_SLEEP
                    if (fsm_state == S_LIGHT_SLEEP)
                        wakeup_timer <= WU_LS_CYCLES;
                    else
                        wakeup_timer <= next_timer;
                end

                S_WAKEUP_DS: begin
                    power_mode   <= PM_DS;
                    iso_en       <= 1'b1;
                    sleep_n      <= 1'b1;   // Power domain re-enabled
                    // Load timer on entry from DEEP_SLEEP
                    if (fsm_state == S_DEEP_SLEEP)
                        wakeup_timer <= WU_DS_CYCLES;
                    else
                        wakeup_timer <= next_timer;
                end

                default: begin
                    power_mode   <= PM_ON;
                    iso_en       <= 1'b0;
                    sleep_n      <= 1'b1;
                    wakeup_timer <= 4'd0;
                end
            endcase
        end
    end

endmodule
