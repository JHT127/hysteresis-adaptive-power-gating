// =============================================================================
// File        : sleep_controller.v
// Module      : sleep_controller
// Description : Generates the footer transistor gate control signals for
//               multiple sleep modes. The 2-bit footer_sel directly maps to
//               the gate bias levels described in p4 (Agarwal/IBM):
//
//                 2'b11 → Active  : footer VG = VDD (fully on, no sleep)
//                 2'b01 → LS      : footer VG = V1 (subthreshold, partial)
//                 2'b00 → DS      : footer VG = 0   (full cut-off)
//
//               The rush_ctrl output implements the two-phase wake-up from
//               p5 (Chang 2012): during wake-up, first enable a small fraction
//               of the footer transistor (rush_ctrl=2'b01) then the full width
//               (rush_ctrl=2'b11) to balance the dI/dt and reduce ground bounce.
//
//               In RTL, these signals abstract the analog bias generator;
//               they serve as control inputs to power intent assertions in UPF
//               and can be mapped to actual MTCMOS sleep pins in synthesis.
// =============================================================================

module sleep_controller (
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  power_mode,    // From power_state_fsm: 00=ON,01=LS,10=DS
    input  wire [2:0]  fsm_state,     // Raw FSM state for wake-up phasing
    output reg  [1:0]  footer_sel,    // Footer gate bias selection (to MTCMOS)
    output reg  [1:0]  rush_ctrl      // Rush-current phase (2-bit, from p5)
);

    // Power mode encoding
    localparam PM_ON = 2'b00;
    localparam PM_LS = 2'b01;
    localparam PM_DS = 2'b10;

    // FSM state encoding (must match power_state_fsm)
    localparam S_ON         = 3'd0;
    localparam S_TO_LS      = 3'd1;
    localparam S_LIGHT_SLEEP= 3'd2;
    localparam S_TO_DS      = 3'd3;
    localparam S_DEEP_SLEEP = 3'd4;
    localparam S_WAKEUP_LS  = 3'd5;
    localparam S_WAKEUP_DS  = 3'd6;

    // Footer selection encoding:
    //   2'b11 = VDD   (Active – footer fully on)
    //   2'b10 = V2    (Dream  – intermediate gate bias, light partial)
    //   2'b01 = V1    (Sleep  – deep partial bias, state retentive)
    //   2'b00 = GND   (Snore  – footer fully off, max leakage savings)
    localparam FTR_ACTIVE = 2'b11;
    localparam FTR_V2     = 2'b10;
    localparam FTR_V1     = 2'b01;
    localparam FTR_OFF    = 2'b00;

    // Rush current control:
    //   2'b00 = both transistors OFF (sleep)
    //   2'b01 = small fraction ON (Phase A/B of p5 wake-up)
    //   2'b11 = full transistor ON (active or final wake-up phase)
    localparam RUSH_OFF   = 2'b00;
    localparam RUSH_PHASE1= 2'b01;  // Small fraction (Mp_a2 only)
    localparam RUSH_FULL  = 2'b11;  // Full width (Mp_a1 + Mp_a2)

    // -------------------------------------------------------------------------
    // Registered output generation
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            footer_sel <= FTR_ACTIVE;
            rush_ctrl  <= RUSH_FULL;
        end else begin
            case (fsm_state)
                S_ON: begin
                    footer_sel <= FTR_ACTIVE;
                    rush_ctrl  <= RUSH_FULL;
                end

                S_TO_LS: begin
                    // Ramp down: intermediate bias before full light sleep
                    footer_sel <= FTR_V2;
                    rush_ctrl  <= RUSH_FULL;
                end

                S_LIGHT_SLEEP: begin
                    footer_sel <= FTR_V1;     // State-retentive partial bias
                    rush_ctrl  <= RUSH_OFF;
                end

                S_TO_DS: begin
                    footer_sel <= FTR_V1;     // Hold LS bias during ramp-in
                    rush_ctrl  <= RUSH_OFF;
                end

                S_DEEP_SLEEP: begin
                    footer_sel <= FTR_OFF;    // Maximum leakage savings
                    rush_ctrl  <= RUSH_OFF;
                end

                S_WAKEUP_LS: begin
                    // Phase 1: small fraction on first (balanced rush from p5)
                    footer_sel <= FTR_V2;
                    rush_ctrl  <= RUSH_PHASE1;
                end

                S_WAKEUP_DS: begin
                    // Phase 1: small fraction first, then full (2-cycle ramp)
                    footer_sel <= FTR_V1;
                    rush_ctrl  <= RUSH_PHASE1;
                end

                default: begin
                    footer_sel <= FTR_ACTIVE;
                    rush_ctrl  <= RUSH_FULL;
                end
            endcase
        end
    end

endmodule
