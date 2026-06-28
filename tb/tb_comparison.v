// =============================================================================
// File        : tb_comparison.v
// Module      : tb_comparison
// Description : Head-to-head comparison: static_pg_top (baseline) vs
//               adaptive_pg_top (proposed). Identical stimulus applied to
//               both DUTs. Prints side-by-side PPA table for the report.
//
//               CORRECTED from the original draft: the baseline DUT is now
//               static_pg_top (fixed-threshold, multi-level sleep capable),
//               not the old static_pg_baseline stub (which had no sleep
//               states at all and therefore could not lose fairly). Counters
//               are now symmetric: both sides track ON/LS/DS cycles, mode
//               transitions, wake-up events, and max wake-up latency from
//               their own power_mode/wakeup_done/wakeup_timer signals.
// =============================================================================

`timescale 1ns/1ps

module tb_comparison;

    reg         clk, rst, req, wakeup_req;
    reg  [3:0]  op;
    reg  [31:0] a, b;

    // Proposed (adaptive) outputs
    wire [31:0] prop_result;
    wire        prop_valid;
    wire [1:0]  prop_power_mode;
    wire        prop_sleep_n, prop_iso_en;
    wire [1:0]  prop_footer_sel, prop_rush_ctrl;
    wire        prop_wakeup_done;
    wire [3:0]  prop_wakeup_timer;

    // Baseline (fixed-threshold) outputs
    wire [31:0] base_result;
    wire        base_valid;
    wire [1:0]  base_power_mode;
    wire        base_sleep_n, base_iso_en;
    wire [1:0]  base_footer_sel, base_rush_ctrl;
    wire        base_wakeup_done;
    wire [3:0]  base_wakeup_timer;

    // -------------------------------------------------------------------------
    // DUT 1: Proposed (adaptive, dual-condition hysteresis predictor)
    // -------------------------------------------------------------------------
    adaptive_pg_top dut_proposed (
        .clk(clk), .rst(rst), .req(req), .op(op), .a(a), .b(b),
        .result(prop_result), .valid(prop_valid),
        .power_mode(prop_power_mode), .sleep_n(prop_sleep_n), .iso_en(prop_iso_en),
        .footer_sel(prop_footer_sel), .rush_ctrl(prop_rush_ctrl),
        .wakeup_done(prop_wakeup_done), .wakeup_timer(prop_wakeup_timer),
        .wakeup_req(wakeup_req)
    );

    // -------------------------------------------------------------------------
    // DUT 2: Baseline (fixed-threshold, single-module substitution per
    // Deliverable 2.5 — same ports as the proposed design, since
    // static_pg_top mirrors adaptive_pg_top's interface exactly)
    // -------------------------------------------------------------------------
    static_pg_top dut_baseline (
        .clk(clk), .rst(rst), .req(req), .op(op), .a(a), .b(b),
        .result(base_result), .valid(base_valid),
        .power_mode(base_power_mode), .sleep_n(base_sleep_n), .iso_en(base_iso_en),
        .footer_sel(base_footer_sel), .rush_ctrl(base_rush_ctrl),
        .wakeup_done(base_wakeup_done), .wakeup_timer(base_wakeup_timer),
        .wakeup_req(wakeup_req)
    );

    initial clk = 0;
    always  #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // Counters — PROPOSED
    // -------------------------------------------------------------------------
    integer p_on, p_ls, p_ds, p_valid, p_trans, p_wu, p_max_lat;
    real    p_leak;
    reg [1:0] p_prev;

    // -------------------------------------------------------------------------
    // Counters — BASELINE (now symmetric with proposed; this is the fix)
    // -------------------------------------------------------------------------
    integer b_on, b_ls, b_ds, b_valid, b_trans, b_wu, b_max_lat;
    real    b_leak;
    reg [1:0] b_prev;

    always @(posedge clk) begin
        if (!rst) begin
            // ---- Proposed ----
            case (prop_power_mode)
                2'b00: begin p_on <= p_on+1; p_leak = p_leak+1.000; end
                2'b01: begin p_ls <= p_ls+1; p_leak = p_leak+0.810; end
                2'b10: begin p_ds <= p_ds+1; p_leak = p_leak+0.640; end
            endcase
            if (prop_valid)        p_valid <= p_valid+1;
            if (prop_wakeup_done)  p_wu    <= p_wu+1;
            if (prop_wakeup_timer > p_max_lat) p_max_lat <= prop_wakeup_timer;
            if (prop_power_mode !== p_prev) begin p_trans <= p_trans+1; p_prev <= prop_power_mode; end

            // ---- Baseline (same accounting, same weights, different DUT) ----
            case (base_power_mode)
                2'b00: begin b_on <= b_on+1; b_leak = b_leak+1.000; end
                2'b01: begin b_ls <= b_ls+1; b_leak = b_leak+0.810; end
                2'b10: begin b_ds <= b_ds+1; b_leak = b_leak+0.640; end
            endcase
            if (base_valid)        b_valid <= b_valid+1;
            if (base_wakeup_done)  b_wu    <= b_wu+1;
            if (base_wakeup_timer > b_max_lat) b_max_lat <= base_wakeup_timer;
            if (base_power_mode !== b_prev) begin b_trans <= b_trans+1; b_prev <= base_power_mode; end
        end
    end

    // -------------------------------------------------------------------------
    // Tasks
    // -------------------------------------------------------------------------
    task alu_op;
        input [3:0] t_op; input [31:0] t_a, t_b;
        begin @(negedge clk); req=1; op=t_op; a=t_a; b=t_b;
              @(posedge clk); #1; req=0; end
    endtask

    task idle_cycles;
        input integer n;
        begin req=0; op=4'hF; a=0; b=0; repeat(n) @(posedge clk); end
    endtask

    task reset_counters;
        begin
            p_on=0; p_ls=0; p_ds=0; p_valid=0; p_trans=0; p_wu=0; p_max_lat=0; p_leak=0.0; p_prev=2'b00;
            b_on=0; b_ls=0; b_ds=0; b_valid=0; b_trans=0; b_wu=0; b_max_lat=0; b_leak=0.0; b_prev=2'b00;
        end
    endtask

    task print_table;
        input [400:1] wl_name;
        integer tot_p, tot_b;
        real sav_p, sav_b, tput_p, tput_b;
        begin
            tot_p = p_on+p_ls+p_ds; tot_b = b_on+b_ls+b_ds;
            sav_p  = (tot_p>0) ? (1.0-p_leak/$itor(tot_p))*100.0 : 0.0;
            sav_b  = (tot_b>0) ? (1.0-b_leak/$itor(tot_b))*100.0 : 0.0;
            tput_p = (tot_p>0) ? ($itor(p_valid)/$itor(tot_p))*100.0 : 0.0;
            tput_b = (tot_b>0) ? ($itor(b_valid)/$itor(tot_b))*100.0 : 0.0;

            $display("\n  WORKLOAD: %0s", wl_name);
            $display("  %-30s %-15s %-15s", "Metric","BASELINE","PROPOSED");
            $display("  %s","------------------------------------------------------------");
            $display("  %-30s %-15d %-15d","Total cycles",tot_b,tot_p);
            $display("  %-30s %-15d %-15d","Cycles ON",b_on,p_on);
            $display("  %-30s %-15d %-15d","Cycles LIGHT SLEEP",b_ls,p_ls);
            $display("  %-30s %-15d %-15d","Cycles DEEP SLEEP",b_ds,p_ds);
            $display("  %-30s %-14.1f%% %-14.1f%%","Leakage saving",sav_b,sav_p);
            $display("  %-30s %-15d %-15d","Valid results",b_valid,p_valid);
            $display("  %-30s %-14.1f%% %-14.1f%%","Throughput rate",tput_b,tput_p);
            $display("  %-30s %-15d %-15d","Mode transitions",b_trans,p_trans);
            $display("  %-30s %-15d %-15d","Wake-up events",b_wu,p_wu);
            $display("  %-30s %-15d %-15d","Max wakeup latency (cyc)",b_max_lat,p_max_lat);
            $display("  %s","------------------------------------------------------------");
        end
    endtask

    // -------------------------------------------------------------------------
    // Main
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("tb_comparison.vcd");
        $dumpvars(0, tb_comparison);
        rst=1; req=0; op=4'hF; a=0; b=0; wakeup_req=0;
        reset_counters;
        repeat(5) @(posedge clk); rst=0; @(posedge clk);

        // WL1: BURST
        $display("\n===========================================================");
        $display("  WORKLOAD 1: BURST (10-op bursts, 1-cycle idle)");
        $display("===========================================================");
        reset_counters;
        repeat(8) begin repeat(10) alu_op(4'b0000,$urandom,$urandom); idle_cycles(1); end
        idle_cycles(5);
        print_table("BURST");
        $display("  [EXPECTED] Baseline thrashes (fixed 3-cycle threshold has no");
        $display("             burst defense); proposed stays ON via rate gate.");

        // WL2: SPARSE
        $display("\n===========================================================");
        $display("  WORKLOAD 2: SPARSE (1 op + 20-cycle idle)");
        $display("===========================================================");
        reset_counters;
        repeat(8) begin alu_op(4'b0001,32'hA5A5_A5A5,32'h1234_5678); idle_cycles(20); end
        idle_cycles(5);
        print_table("SPARSE");
        $display("  [EXPECTED] Both reach Deep Sleep; savings should be comparable");
        $display("             here (H2) since idle is unambiguous either way.");

        // WL3: MIXED
        $display("\n===========================================================");
        $display("  WORKLOAD 3: MIXED (dense bursts + sparse phases)");
        $display("===========================================================");
        reset_counters;
        repeat(4) begin repeat(15) alu_op(4'b0011,$urandom,$urandom); idle_cycles(1); end
        repeat(6) begin alu_op(4'b0100,$urandom,$urandom); idle_cycles(12); end
        repeat(3) begin repeat(10) alu_op(4'b0000,$urandom,$urandom); idle_cycles(2); end
        idle_cycles(5);
        print_table("MIXED");
        $display("  [EXPECTED] Proposed shows fewer transitions than baseline (H1)");
        $display("             during this workload's dense sub-phases.");

        $display("\n===========================================================");
        $display("  CORRECTNESS CHECK: mismatches logged above (expect 0 while");
        $display("  BOTH dut_baseline and dut_proposed report valid=1)");
        $display("===========================================================");
        $display("\nSIMULATION COMPLETE.");
        $finish;
    end

    // Correctness checker — only meaningful while neither DUT is isolating
    // (clamped) results; mismatches during isolation are expected, not bugs.
    always @(posedge clk) begin
        if (!rst && base_valid && prop_valid)
            if (base_result !== prop_result)
                $display("[MISMATCH] T=%0t base=0x%08h prop=0x%08h",$time,base_result,prop_result);
    end

    initial begin #5_000_000; $display("[TIMEOUT]"); $finish; end

endmodule
