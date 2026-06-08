#!/bin/bash
# =============================================================================
# File        : run_sim.sh
# Description : Run RTL simulation using Icarus Verilog (iverilog)
# Usage       : bash scripts/run_sim.sh
# =============================================================================

set -e

RTL_DIR=rtl
TB_DIR=tb
OUT_DIR=sim_out

mkdir -p $OUT_DIR

echo "=== Compiling RTL + Testbench ==="
iverilog -g2012 -o $OUT_DIR/sim.vvp \
    $RTL_DIR/alu_32bit.v            \
    $RTL_DIR/activity_monitor.v     \
    $RTL_DIR/hysteresis_predictor.v \
    $RTL_DIR/power_state_fsm.v      \
    $RTL_DIR/sleep_controller.v     \
    $RTL_DIR/isolation_ctrl.v       \
    $RTL_DIR/adaptive_pg_top.v      \
    $TB_DIR/tb_adaptive_pg_top.v

echo "=== Running Simulation ==="
cd $OUT_DIR
vvp sim.vvp

echo "=== Simulation complete. VCD: $OUT_DIR/tb_adaptive_pg_top.vcd ==="
echo "    Open waveforms: gtkwave $OUT_DIR/tb_adaptive_pg_top.vcd"
