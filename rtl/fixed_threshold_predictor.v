// =============================================================================
// File        : fixed_threshold_predictor.v
// Module      : fixed_threshold_predictor
// Description : BASELINE decision logic — drop-in replacement for
//               hysteresis_predictor.v in the adaptive design. Implements a
//               static, idle-cycle-count-only mode-selection policy with a
//               single fixed threshold per sleep mode:
//                 - No activity_rate input (idle_count is the only signal).
//                 - No hysteresis band: exit threshold == entry threshold.
//                 - No ADAPT_OFFSET widening: thresholds never shift.
//
//               This module is purely a function of idle_count (memoryless
//               w.r.t. the previous sleep_req), unlike hysteresis_predictor.v,
//               which is stateful (its decision depends on the current mode).
//               That difference is the entire experimental variable between
//               the baseline and the adaptive design — everything else in the
//               controller (power_state_fsm, sleep_controller, isolation_ctrl,
//               activity_monitor, alu_32bit, UPF) is shared, unmodified.
//
// Reference   : K. Agarwal, H. Deogun, D. Sylvester, K. Nowka, "Power Gating
//               with Multiple Sleep Modes," ISQED 2006, pp. 633-637 — the
//               idle-cycle-count-only mode-selection policy this baseline
//               replicates.
//
// Output encoding (sleep_req) — identical to hysteresis_predictor.v so this
// module plugs into the unmodified power_state_fsm.v with no other changes:
//   2'b00 = Request ON (wake up / stay active)
//   2'b01 = Request LIGHT SLEEP
//   2'b10 = Request DEEP SLEEP
// =============================================================================

module fixed_threshold_predictor #(
    parameter LS_THRESH = 8'd3,    // Fixed idle-cycle threshold to enter Light Sleep
    parameter DS_THRESH = 8'd8     // Fixed idle-cycle threshold to enter Deep Sleep
)(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] idle_count,  // From activity_monitor (only signal used)
    output reg  [1:0] sleep_req    // Requested power state
);

    localparam MODE_ON = 2'b00;
    localparam MODE_LS = 2'b01;  // Light Sleep
    localparam MODE_DS = 2'b10;  // Deep Sleep

    // -------------------------------------------------------------------------
    // Combinational decision: idle_count alone selects the mode. No case
    // statement keyed on the current sleep_req is needed, because there is no
    // hysteresis band — the same threshold governs both entry and exit.
    // -------------------------------------------------------------------------
    reg [1:0] next_sleep_req;

    always @(*) begin
        if (idle_count >= DS_THRESH)
            next_sleep_req = MODE_DS;
        else if (idle_count >= LS_THRESH)
            next_sleep_req = MODE_LS;
        else
            next_sleep_req = MODE_ON;
    end

    // -------------------------------------------------------------------------
    // Register the prediction (one cycle pipeline) — matches
    // hysteresis_predictor.v's timing exactly, so the comparison isolates
    // decision logic only, not pipeline-depth differences.
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            sleep_req <= MODE_ON;
        else
            sleep_req <= next_sleep_req;
    end

endmodule
