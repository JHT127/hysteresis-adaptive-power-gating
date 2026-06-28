// =============================================================================
// File   : filelist.f
// Usage  : passed to vcs via -f filelist.f
// Note   : Contains RTL sources only. The testbench (top module) is passed
//          separately on the command line so the same filelist serves both
//          tb_adaptive_pg_top.v (regression) and tb_comparison.v (baseline
//          vs proposed). Both adaptive_pg_top and static_pg_top are listed
//          so either or both can be elaborated depending on which TB is
//          compiled alongside this list.
// =============================================================================
+incdir+./rtl

./rtl/alu_32bit.v
./rtl/activity_monitor.v
./rtl/hysteresis_predictor.v
./rtl/fixed_threshold_predictor.v
./rtl/power_state_fsm.v
./rtl/sleep_controller.v
./rtl/isolation_ctrl.v
./rtl/adaptive_pg_top.v
./rtl/static_pg_top.v
