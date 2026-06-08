// =============================================================================
// File        : adaptive_pg_top.v
// Module      : adaptive_pg_top
// Description : Top-level integration of the Adaptive Multi-Level Power Gating
//               Controller for a 32-bit ALU SoC block.
//
//               Instantiates and connects:
//                 1. alu_32bit            — the power-managed functional block
//                 2. activity_monitor     — rolling window activity tracker
//                 3. hysteresis_predictor — adaptive sleep-mode predictor
//                 4. power_state_fsm      — 7-state power management FSM
//                 5. sleep_controller     — footer gate bias sequencer
//                 6. isolation_ctrl       — output isolation clamping
//
//               Power-mode observable outputs are exported for testbench
//               measurement of leakage savings, wake-up latency, and throughput.
//
// Target      : Generic technology (synthesizable with Synopsys DC)
//               Power domains defined in ../upf/adaptive_pg.upf
// =============================================================================

module adaptive_pg_top (
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
    // Internal wire declarations
    // -------------------------------------------------------------------------
    wire        alu_active;
    wire [7:0]  idle_count;
    wire [7:0]  activity_rate;
    wire        is_idle;
    wire [1:0]  sleep_req;
    wire [2:0]  fsm_state;
    wire [31:0] alu_result_raw;
    wire        alu_valid_raw;
    wire        iso_en_int;
    wire        sleep_n_int;
    wire [1:0]  power_mode_int;
    wire [2:0]  fsm_state_int;

    // -------------------------------------------------------------------------
    // Instance 1: 32-bit ALU (power-gated functional block)
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
    // Instance 2: Activity Monitor
    // -------------------------------------------------------------------------
    activity_monitor #(
        .WINDOW_SIZE (16),
        .IDLE_MAX    (255)
    ) u_act_mon (
        .clk           (clk),
        .rst           (rst),
        .alu_active    (alu_active),
        .idle_count    (idle_count),
        .activity_rate (activity_rate),
        .is_idle       (is_idle)
    );

    // -------------------------------------------------------------------------
    // Instance 3: Hysteresis Predictor (novel adaptive component)
    // -------------------------------------------------------------------------
    hysteresis_predictor #(
        .LS_IDLE_ENTER    (8'd3),
        .DS_IDLE_ENTER    (8'd8),
        .LS_IDLE_EXIT     (8'd1),
        .DS_IDLE_EXIT     (8'd4),
        .LS_RATE_ENTER    (8'd64),
        .DS_RATE_ENTER    (8'd26),
        .HIGH_RATE_THRESH (8'd128),
        .ADAPT_OFFSET     (8'd4)
    ) u_hyst_pred (
        .clk           (clk),
        .rst           (rst),
        .idle_count    (idle_count),
        .activity_rate (activity_rate),
        .sleep_req     (sleep_req)
    );

    // -------------------------------------------------------------------------
    // Instance 4: Power State FSM
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
    // Instance 5: Sleep Controller (footer bias + rush current sequencer)
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
    // Instance 6: Isolation Controller (domain boundary clamping)
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
