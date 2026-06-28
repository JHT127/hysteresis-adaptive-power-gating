// =============================================================================
// File        : tb_adaptive_pg_top.v
// Module      : tb_adaptive_pg_top
// Description : Comprehensive testbench for the Adaptive Multi-Level Power
//               Gating Controller. Applies three synthetic workload patterns
//               to evaluate the controller's behaviour:
//
//   WORKLOAD 1 — BURST: Dense computation bursts separated by short idle gaps
//                (tests: no premature sleep during bursty work)
//   WORKLOAD 2 — SPARSE: Occasional operations with long idle gaps
//                (tests: proper transition to LIGHT then DEEP sleep)
//   WORKLOAD 3 — MIXED: Alternating dense and sparse phases
//                (tests: adaptive threshold adjustment and hysteresis)
//
//               Metrics collected:
//                 - Cycles in each power mode → leakage savings estimate
//                 - Wake-up latency on each transition (wakeup_timer)
//                 - Valid result throughput (valid pulses counted)
//                 - Number of mode transitions (thrashing check)
//
// Leakage model (based on p4 Agarwal results):
//   Leakage_ON = 1.0 (baseline)
//   Leakage_LS = 0.81 (19% reduction, state-retentive)
//   Leakage_DS = 0.64 (36% reduction, non-state-retentive)
// =============================================================================

`timescale 1ns/1ps

module tb_adaptive_pg_top;

    // -------------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------------
    reg         clk;
    reg         rst;
    reg         req;
    reg  [3:0]  op;
    reg  [31:0] a, b;
    wire [31:0] result;
    wire        valid;
    wire [1:0]  power_mode;
    wire        sleep_n;
    wire        iso_en;
    wire [1:0]  footer_sel;
    wire [1:0]  rush_ctrl;
    wire        wakeup_done;
    wire [3:0]  wakeup_timer;
    reg         wakeup_req;

    // -------------------------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------------------------
    adaptive_pg_top dut (
        .clk          (clk),
        .rst          (rst),
        .req          (req),
        .op           (op),
        .a            (a),
        .b            (b),
        .result       (result),
        .valid        (valid),
        .power_mode   (power_mode),
        .sleep_n      (sleep_n),
        .iso_en       (iso_en),
        .footer_sel   (footer_sel),
        .rush_ctrl    (rush_ctrl),
        .wakeup_done  (wakeup_done),
        .wakeup_timer (wakeup_timer),
        .wakeup_req   (wakeup_req)
    );

    // -------------------------------------------------------------------------
    // Clock: 10 ns period (100 MHz)
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // Performance counters
    // -------------------------------------------------------------------------
    integer cycles_on, cycles_ls, cycles_ds;
    integer valid_count;
    integer mode_transitions;
    integer wakeup_events;
    real    leakage_integral;  // Weighted leakage over time (normalized)

    reg [1:0] prev_power_mode;

    // -------------------------------------------------------------------------
    // Monitor: track mode changes and accumulate leakage integral
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst) begin
            // Count cycles per mode
            case (power_mode)
                2'b00: begin cycles_on <= cycles_on + 1; leakage_integral <= leakage_integral + 1.0;   end
                2'b01: begin cycles_ls <= cycles_ls + 1; leakage_integral <= leakage_integral + 0.81;  end
                2'b10: begin cycles_ds <= cycles_ds + 1; leakage_integral <= leakage_integral + 0.64;  end
                default: ;
            endcase
            // Count valid results
            if (valid) valid_count <= valid_count + 1;
            // Count wakeup events
            if (wakeup_done) wakeup_events <= wakeup_events + 1;
            // Count mode transitions
            if (power_mode !== prev_power_mode) begin
                mode_transitions <= mode_transitions + 1;
                $display("[T=%0t] Mode transition: %0d -> %0d  (iso=%b sleep_n=%b footer=%b)",
                         $time, prev_power_mode, power_mode, iso_en, sleep_n, footer_sel);
            end
            prev_power_mode <= power_mode;
        end
    end

    // -------------------------------------------------------------------------
    // Helper tasks
    // -------------------------------------------------------------------------

    // Issue one ALU operation
    task alu_op;
        input [3:0]  op_in;
        input [31:0] a_in, b_in;
        begin
            @(negedge clk);
            req = 1; op = op_in; a = a_in; b = b_in;
            @(negedge clk);
            req = 0;
        end
    endtask

    // Idle for N cycles
    task idle_cycles;
        input integer n;
        integer i;
        begin
            req = 0;
            repeat(n) @(posedge clk);
        end
    endtask

    // Print separator
    task print_section;
        input [200*8:1] label;
        begin
            $display("");
            $display("=======================================================");
            $display(" %s", label);
            $display("=======================================================");
        end
    endtask

    // -------------------------------------------------------------------------
    // Main test sequence
    // -------------------------------------------------------------------------
    initial begin
        // Dump waveforms
        $dumpfile("tb_adaptive_pg_top.vcd");
        $dumpvars(0, tb_adaptive_pg_top);

        // Init
        rst = 1; req = 0; op = 4'hF; a = 0; b = 0; wakeup_req = 0;
        cycles_on = 0; cycles_ls = 0; cycles_ds = 0;
        valid_count = 0; mode_transitions = 0; wakeup_events = 0;
        leakage_integral = 0.0; prev_power_mode = 2'b00;
        repeat(5) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // =================================================================
        // WORKLOAD 1: BURST — dense computation, short idle gaps (5 cycles)
        // Expected: controller should NOT enter sleep (hysteresis prevents it)
        // =================================================================
        print_section("WORKLOAD 1: BURST (dense computation, 5-cycle gaps)");
        repeat(8) begin
            // 10 operations in a row
            repeat(10) alu_op(4'b0000, $random, $random);
            // Short idle — below LS threshold of 3 cycles
            idle_cycles(2);
        end
        // Verify: should still be in ON mode (no premature sleep)
        $display("[BURST] Power mode after burst = %0d (expected 0=ON)", power_mode);
        if (power_mode !== 2'b00)
            $display("[WARN] Unexpected sleep during burst workload!");

        // =================================================================
        // WORKLOAD 2: SPARSE — long idle gaps (20 cycles between operations)
        // Expected: transitions to LIGHT SLEEP then DEEP SLEEP
        // =================================================================
        print_section("WORKLOAD 2: SPARSE (long idle gaps, 20 cycles)");
        repeat(6) begin
            // Single operation
            alu_op(4'b0001, 32'hA5A5A5A5, 32'h12345678);
            // Long idle — triggers LS then DS
            idle_cycles(20);
        end
        $display("[SPARSE] Power mode near end = %0d (expected 2=DS)", power_mode);

        // =================================================================
        // WORKLOAD 3: EXTERNAL WAKEUP — force wake from deep sleep
        // =================================================================
        print_section("WORKLOAD 3: EXTERNAL WAKEUP from Deep Sleep");
        // Let system settle into deep sleep
        idle_cycles(15);
        $display("[WAKEUP] Before wakeup_req: mode=%0d (expect DS=2)", power_mode);
        // Assert external wake-up
        @(negedge clk);
        wakeup_req = 1;
        @(posedge clk);
        wakeup_req = 0;
        // Wait for wake-up to complete
        wait(wakeup_done == 1'b1);
        @(posedge clk);
        $display("[WAKEUP] After wakeup_done: mode=%0d (expect ON=0)", power_mode);
        // Now do work
        repeat(5) alu_op(4'b0010, $random, $random);

        // =================================================================
        // WORKLOAD 4: MIXED — alternating dense and sparse phases
        // Expected: adaptive hysteresis correctly classifies each phase
        // =================================================================
        print_section("WORKLOAD 4: MIXED (alternating dense/sparse)");
        repeat(4) begin
            // Dense phase (should stay ON due to adaptive widening)
            repeat(15) alu_op(4'b0011, $random, $random);
            idle_cycles(1);  // Very brief idle
        end
        // Now go sparse
        repeat(4) begin
            alu_op(4'b0100, $random, $random);
            idle_cycles(12);  // Long enough for LS but not DS
        end

        // =================================================================
        // WORKLOAD 5: SUSTAINED IDLE — force full deep sleep cycle
        // =================================================================
        print_section("WORKLOAD 5: SUSTAINED IDLE (35 cycles)");
        idle_cycles(35);
        $display("[IDLE] Power mode after 35 idle = %0d (expect DS=2)", power_mode);

        // Wake up and verify results are valid
        alu_op(4'b0000, 32'h0000_FFFF, 32'h0000_0001);
        // Wait for wake-up
        wait(power_mode == 2'b00);
        alu_op(4'b0000, 32'h0000_FFFF, 32'h0000_0001);
        @(posedge clk); @(posedge clk);
        $display("[IDLE->ON] result=0x%08h (expect 0x00010000)", result);

        // =================================================================
        // Final statistics
        // =================================================================
        repeat(10) @(posedge clk);  // settle

        print_section("SIMULATION RESULTS SUMMARY");
        $display("");
        $display("  Total cycles simulated  : %0d", cycles_on + cycles_ls + cycles_ds);
        $display("  Cycles in ON            : %0d", cycles_on);
        $display("  Cycles in LIGHT SLEEP   : %0d", cycles_ls);
        $display("  Cycles in DEEP  SLEEP   : %0d", cycles_ds);
        $display("  Valid results issued    : %0d", valid_count);
        $display("  Wake-up events          : %0d", wakeup_events);
        $display("  Mode transitions        : %0d", mode_transitions);
        $display("");
        $display("  --- Leakage Analysis (normalized to all-ON baseline) ---");
        $display("  Leakage integral (weighted): %.2f", leakage_integral);
        $display("  Baseline (all ON)           : %.2f", $itor(cycles_on + cycles_ls + cycles_ds));
        if ((cycles_on + cycles_ls + cycles_ds) > 0) begin
            $display("  Leakage saving              : %.1f%%",
                (1.0 - leakage_integral / $itor(cycles_on + cycles_ls + cycles_ds)) * 100.0);
        end
        $display("");
        $display("  [NOTE] Light Sleep = 19%% leakage reduction (state retentive)");
        $display("  [NOTE] Deep  Sleep = 36%% leakage reduction (Agarwal p4 model)");
        $display("");
        $display("SIMULATION COMPLETE.");
        $finish;
    end

    // -------------------------------------------------------------------------
    // Timeout watchdog (prevent infinite hang)
    // -------------------------------------------------------------------------
    initial begin
        #1_000_000;
        $display("[ERROR] Simulation TIMEOUT");
        $finish;
    end

endmodule
