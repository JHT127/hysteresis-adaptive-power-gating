// =============================================================================
// File        : static_pg_top.v
// Module      : static_pg_top
// Description : BASELINE top-level — structurally identical to
//               adaptive_pg_top.v. The ONLY difference is that
//               hysteresis_predictor.v is replaced by
//               fixed_threshold_predictor.v. Every other module instance
//               (alu_32bit, activity_monitor, power_state_fsm,
//               sleep_controller, isolation_ctrl) and every port on this
//               top-level are unchanged, so this design can be driven by the
//               same testbench stimulus and the same UPF power intent as
//               adaptive_pg_top.v, satisfying the Fair-Comparison Protocol
//               (Deliverable 1) and the Baseline Controller Specification
//               (Deliverable 2.5).
//
//               activity_monitor's activity_rate and is_idle outputs are
//               instantiated identically (for area-fairness — the baseline
//               pays the same activity_monitor area cost as the adaptive
//               design) but left unconnected, since
//               fixed_threshold_predictor only consumes idle_count.
//
// Target      : Generic technology (synthesizable with Synopsys DC)
//               Power domains defined in ../upf/adaptive_pg.upf (same UPF
//               file as adaptive_pg_top.v — instance names u_alu, u_act_mon,
//               u_pg_fsm, u_sleep_ctrl match, so the existing UPF applies
//               without modification).
// =============================================================================

module static_pg_top (
    // ---- Global ----
    input  wire        clk,
    input  wire        rst,

    // ---- ALU interface (from upstream logic / testbench) ----
    input  wire        req,          // Request: ALU operation this cycle
    input  wire [3:0]  op,           // ALU operation select
    input  wire [31:0] a,            // Operand A
    input  wire [31:0] b,            // Operand B

    // ---- ALU result (to downstream / testbench) ----
    output wire [31:0] result,       // Isolated ALU result
    output wire        valid,        // Isolated ALU valid

    // ---- Power management observability ----
    output wire [1:0]  power_mode,   // Current power state: 00=ON,01=LS,10=DS
    output wire        sleep_n,      // Active-low sleep to power domain
    output wire        iso_en,       // Isolation enable
    output wire [1:0]  footer_sel,   // Footer gate bias selection
    output wire [1:0]  rush_ctrl,    // Rush-current phase control
    output wire        wakeup_done,  // Pulses when wake-up completes
    output wire [3:0]  wakeup_timer, // Remaining wake-up cycles

    // ---- External wake-up override ----
    input  wire        wakeup_req    // External request to force wake-up
);

    // -------------------------------------------------------------------------
    // Internal wire declarations (mirrors adaptive_pg_top.v exactly)
    // -------------------------------------------------------------------------
    wire        alu_active;
    wire [7:0]  idle_count;
    wire [1:0]  sleep_req;
    wire [31:0] alu_result_raw;
    wire        alu_valid_raw;
    wire        iso_en_int;
    wire        sleep_n_int;
    wire [1:0]  power_mode_int;
    wire [2:0]  fsm_state_int;

    // -------------------------------------------------------------------------
    // Instance 1: 32-bit ALU (power-gated functional block) — unchanged
    // -------------------------------------------------------------------------
    alu_32bit u_alu (
        .clk        (clk),
        .rst        (rst),
        .en         (req),
        .op         (op),
        .a          (a),
        .b          (b),
        .result     (alu_result_raw),
        .valid      (alu_valid_raw),
        .alu_active (alu_active)
    );

    // -------------------------------------------------------------------------
    // Instance 2: Activity Monitor — unchanged (activity_rate/is_idle unused
    // by the baseline's predictor, left unconnected)
    // -------------------------------------------------------------------------
    activity_monitor #(
        .WINDOW_SIZE (16),
        .IDLE_MAX    (255)
    ) u_act_mon (
        .clk           (clk),
        .rst           (rst),
        .alu_active    (alu_active),
        .idle_count    (idle_count),
        .activity_rate (),
        .is_idle       ()
    );

    // -------------------------------------------------------------------------
    // Instance 3: Fixed-Threshold Predictor — THE ONLY SUBSTITUTED MODULE
    // -------------------------------------------------------------------------
    fixed_threshold_predictor #(
        .LS_THRESH (8'd3),
        .DS_THRESH (8'd8)
    ) u_fixed_pred (
        .clk        (clk),
        .rst        (rst),
        .idle_count (idle_count),
        .sleep_req  (sleep_req)
    );

    // -------------------------------------------------------------------------
    // Instance 4: Power State FSM — unchanged
    // -------------------------------------------------------------------------
    power_state_fsm #(
        .WU_LS_CYCLES (4'd3),
        .WU_DS_CYCLES (4'd8)
    ) u_pg_fsm (
        .clk          (clk),
        .rst          (rst),
        .sleep_req    (sleep_req),
        .wakeup_req   (wakeup_req),
        .fsm_state    (fsm_state_int),
        .power_mode   (power_mode_int),
        .iso_en       (iso_en_int),
        .sleep_n      (sleep_n_int),
        .wakeup_done  (wakeup_done),
        .wakeup_timer (wakeup_timer)
    );

    // -------------------------------------------------------------------------
    // Instance 5: Sleep Controller — unchanged
    // -------------------------------------------------------------------------
    sleep_controller u_sleep_ctrl (
        .clk        (clk),
        .rst        (rst),
        .power_mode (power_mode_int),
        .fsm_state  (fsm_state_int),
        .footer_sel (footer_sel),
        .rush_ctrl  (rush_ctrl)
    );

    // -------------------------------------------------------------------------
    // Instance 6: Isolation Controller — unchanged
    // -------------------------------------------------------------------------
    isolation_ctrl #(
        .DATA_WIDTH (32),
        .ISO_VALUE  (32'd0)
    ) u_iso_ctrl (
        .iso_en    (iso_en_int),
        .data_in   (alu_result_raw),
        .valid_in  (alu_valid_raw),
        .data_out  (result),
        .valid_out (valid)
    );

    // -------------------------------------------------------------------------
    // Drive top-level outputs
    // -------------------------------------------------------------------------
    assign power_mode = power_mode_int;
    assign sleep_n    = sleep_n_int;
    assign iso_en     = iso_en_int;

endmodule
