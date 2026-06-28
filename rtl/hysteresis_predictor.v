// =============================================================================
// File        : hysteresis_predictor.v
// Module      : hysteresis_predictor
// Description : Adaptive hysteresis predictor — the NOVEL contribution of this
//               project. Determines which sleep mode to request based on:
//                 (1) idle_count  : consecutive idle cycles
//                 (2) activity_rate : rolling window occupancy (0–255)
//
//               Hysteresis bands prevent rapid state toggling:
//                 - Enter threshold > exit threshold for each sleep mode
//               Adaptive component: the thresholds are shifted (widened) when
//               recent activity_rate was high, avoiding premature sleep entry
//               during bursty workloads.
//
// Novelty     : Unlike p4 (Agarwal/IBM) which uses fixed idle-cycle thresholds
//               (3/5/8 cycles), this predictor uses a dual-condition gate
//               (idle_count AND activity_rate) with hysteresis bands that widen
//               under bursty conditions. This prevents the "thrashing" of rapid
//               sleep/wake transitions seen in static-threshold designs.
//
// Output encoding (sleep_req):
//   2'b00 = Request ON (wake up / stay active)
//   2'b01 = Request LIGHT SLEEP
//   2'b10 = Request DEEP SLEEP
// =============================================================================

module hysteresis_predictor #(
    // ---- Entry thresholds (idle_count must EXCEED to enter sleep) ----
    parameter LS_IDLE_ENTER     = 8'd3,    // Cycles idle to enter Light Sleep
    parameter DS_IDLE_ENTER     = 8'd8,    // Cycles idle to enter Deep Sleep
    // ---- Exit thresholds (idle_count must FALL BELOW to exit sleep) ----
    parameter LS_IDLE_EXIT      = 8'd1,    // Hysteresis: exit LS if idle < 1
    parameter DS_IDLE_EXIT      = 8'd4,    // Hysteresis: exit DS if idle < 4
    // ---- Activity-rate thresholds (rate must be LOW to allow sleep) ----
    parameter LS_RATE_ENTER     = 8'd64,   // activity_rate < 64/256 = 25% for LS
    parameter DS_RATE_ENTER     = 8'd26,   // activity_rate < 26/256 = 10% for DS
    // ---- Adaptive widening: if rate > this, add ADAPT_OFFSET to thresholds ----
    parameter HIGH_RATE_THRESH  = 8'd128,  // 50% activity rate is "bursty"
    parameter ADAPT_OFFSET      = 8'd4     // Extra idle cycles required when bursty
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] idle_count,     // From activity_monitor
    input  wire [7:0] activity_rate,  // From activity_monitor
    output reg  [1:0] sleep_req       // Requested power state
);

    // -------------------------------------------------------------------------
    // Adaptive threshold computation
    // -------------------------------------------------------------------------
    wire [8:0] ls_idle_thresh;  // 9-bit to avoid overflow
    wire [8:0] ds_idle_thresh;

    // Widen thresholds when workload is bursty (prevents premature sleep)
    assign ls_idle_thresh = (activity_rate > HIGH_RATE_THRESH)
                            ? (LS_IDLE_ENTER + ADAPT_OFFSET)
                            : LS_IDLE_ENTER;
    assign ds_idle_thresh = (activity_rate > HIGH_RATE_THRESH)
                            ? (DS_IDLE_ENTER + ADAPT_OFFSET)
                            : DS_IDLE_ENTER;

    // -------------------------------------------------------------------------
    // Hysteresis state machine (combinational with registered output)
    // Uses previous sleep_req for hysteresis banding
    // -------------------------------------------------------------------------
    reg [1:0] next_sleep_req;

    localparam MODE_ON    = 2'b00;
    localparam MODE_LS    = 2'b01;  // Light Sleep
    localparam MODE_DS    = 2'b10;  // Deep Sleep

    always @(*) begin
        case (sleep_req)

            // -----------------------------------------------------------------
            // Currently ON: check conditions to enter a sleep mode
            // -----------------------------------------------------------------
            MODE_ON: begin
                // Enter DEEP SLEEP directly if idle is very long and very quiet
                if ((idle_count >= ds_idle_thresh[7:0]) &&
                    (activity_rate < DS_RATE_ENTER)) begin
                    next_sleep_req = MODE_DS;
                end
                // Enter LIGHT SLEEP if moderately idle
                else if ((idle_count >= ls_idle_thresh[7:0]) &&
                         (activity_rate < LS_RATE_ENTER)) begin
                    next_sleep_req = MODE_LS;
                end
                else begin
                    next_sleep_req = MODE_ON;
                end
            end

            // -----------------------------------------------------------------
            // Currently LIGHT SLEEP: escalate to deep or return to ON
            // -----------------------------------------------------------------
            MODE_LS: begin
                // Wake up: if idle_count dropped below exit hysteresis band
                if (idle_count < LS_IDLE_EXIT) begin
                    next_sleep_req = MODE_ON;
                end
                // Escalate to deep sleep if idle persists and rate is very low
                else if ((idle_count >= ds_idle_thresh[7:0]) &&
                         (activity_rate < DS_RATE_ENTER)) begin
                    next_sleep_req = MODE_DS;
                end
                else begin
                    next_sleep_req = MODE_LS;
                end
            end

            // -----------------------------------------------------------------
            // Currently DEEP SLEEP: only return to ON (not directly to LS)
            // Full wake-up through ON then re-evaluate
            // -----------------------------------------------------------------
            MODE_DS: begin
                if (idle_count < DS_IDLE_EXIT) begin
                    next_sleep_req = MODE_ON;
                end else begin
                    next_sleep_req = MODE_DS;
                end
            end

            default: next_sleep_req = MODE_ON;
        endcase
    end

    // -------------------------------------------------------------------------
    // Register the prediction (one cycle pipeline to avoid combinational loops)
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            sleep_req <= MODE_ON;
        else
            sleep_req <= next_sleep_req;
    end

endmodule
