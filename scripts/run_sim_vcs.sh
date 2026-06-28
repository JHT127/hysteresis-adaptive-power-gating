#!/bin/bash
# =============================================================================
# File        : run_sim_vcs.sh
# Description : Run RTL simulation using Synopsys VCS
# Usage       : bash scripts/run_sim_vcs.sh
# =============================================================================

set -e

RTL_DIR=rtl
TB_DIR=tb
OUT_DIR=sim_out

mkdir -p $OUT_DIR

echo "=== Compiling RTL + Testbench with Synopsys VCS ==="
vcs -sverilog -full64 -debug_access+all -timescale=1ns/1ps -l $OUT_DIR/vcs_compile.log \
    $RTL_DIR/alu_32bit.v            \
    $RTL_DIR/activity_monitor.v     \
    $RTL_DIR/hysteresis_predictor.v \
    $RTL_DIR/power_state_fsm.v      \
    $RTL_DIR/sleep_controller.v     \
    $RTL_DIR/isolation_ctrl.v       \
    $RTL_DIR/adaptive_pg_top.v      \
    $TB_DIR/tb_adaptive_pg_top.v

echo "=== Running Simulation ==="
./simv -l $OUT_DIR/vcs_sim.log

echo "=== Simulation complete. ==="
echo "To view waveforms, use Synopsys DVE:"
echo "dve -vpd inter.vpd &"
