# =============================================================================
# File        : dc_synthesis.tcl
# Tool        : Synopsys Design Compiler (DC)
# Description : Synthesis script for the Adaptive Multi-Level Power Gating
#               Controller. Produces timing, area, and power reports for TWO
#               design points as required:
#                 (A) LOW POWER  : tight leakage budget, relaxed timing
#                 (B) HIGH SPEED : tight timing, relaxed leakage
#
# Usage       : dc_shell -f scripts/dc_synthesis.tcl | tee reports/dc_run.log
# =============================================================================

# --------------------------------------------------------------------------
# 0. Environment setup — adjust library paths for your installation
# --------------------------------------------------------------------------
set DESIGN_NAME  "adaptive_pg_top"
set RTL_DIR      "../rtl"
set REPORTS_DIR  "../reports"
set OUTPUTS_DIR  "../netlists"
set UPF_FILE     "../upf/adaptive_pg.upf"

# Technology library: use generic or your installed PDK
# Example for SAED 32nm EDK (replace with your actual path):
# set TARGET_LIB   "/path/to/saed32nm/lib/stdcell_rvt/db_ccs/saed32rvt_tt0p78v25c.db"
# For generic flow without a real PDK:
set TARGET_LIB   "typical.db"   ;# Replace with your library
set LINK_LIB     [list "*" $TARGET_LIB]

file mkdir $REPORTS_DIR
file mkdir $OUTPUTS_DIR

# --------------------------------------------------------------------------
# 1. Read RTL sources
# --------------------------------------------------------------------------
analyze -format verilog [list \
    $RTL_DIR/alu_32bit.v            \
    $RTL_DIR/activity_monitor.v     \
    $RTL_DIR/hysteresis_predictor.v \
    $RTL_DIR/power_state_fsm.v      \
    $RTL_DIR/sleep_controller.v     \
    $RTL_DIR/isolation_ctrl.v       \
    $RTL_DIR/adaptive_pg_top.v      \
]

elaborate $DESIGN_NAME
link
current_design $DESIGN_NAME

# --------------------------------------------------------------------------
# 2. Load UPF power intent
# --------------------------------------------------------------------------
# load_upf $UPF_FILE    ;# Uncomment if UPF-aware synthesis is supported

# --------------------------------------------------------------------------
# 3. Clock and timing constraints
# --------------------------------------------------------------------------
# Clock: 100 MHz (10 ns period)
create_clock -period 10.0 -name clk [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks clk]
set_clock_transition  0.1 [get_clocks clk]

# Input/output delays (assume 20% of clock period for IO)
set_input_delay  2.0 -clock clk [remove_from_collection [all_inputs]  [get_ports clk]]
set_output_delay 2.0 -clock clk [all_outputs]

# Drive strength (assume driving from a standard flip-flop output)
set_driving_cell -lib_cell DFFRX1 -pin Q [all_inputs]
set_load 0.05 [all_outputs]  ;# 50 fF load on outputs

# Don't touch reset (async/sync reset is combinationally simple)
set_false_path -from [get_ports rst]

# --------------------------------------------------------------------------
# 4. Design constraints
# --------------------------------------------------------------------------
set_max_area 0  ;# Minimize area (DC will try to minimize)

# --------------------------------------------------------------------------
# DESIGN POINT A: LOW POWER (relaxed 15 ns timing, optimize for leakage)
# --------------------------------------------------------------------------
echo "=== DESIGN POINT A: LOW POWER SYNTHESIS ==="

# Relax timing for low-power optimization
create_clock -period 15.0 -name clk_lp [get_ports clk]
set_max_leakage_power 0          ;# Minimize leakage power
set_leakage_optimization true
compile_ultra -no_autoungroup -gate_clock

# Write reports for low power point
report_timing  -nworst 5 -delay_type max > $REPORTS_DIR/timing_lp.rpt
report_area                              > $REPORTS_DIR/area_lp.rpt
report_power   -analysis_effort high     > $REPORTS_DIR/power_lp.rpt
report_qor                               > $REPORTS_DIR/qor_lp.rpt
report_constraint -all_violators         > $REPORTS_DIR/constraints_lp.rpt

# Write netlist
write_file -format verilog -hierarchy -output $OUTPUTS_DIR/${DESIGN_NAME}_lp.v
write_sdc  -nosplit $OUTPUTS_DIR/${DESIGN_NAME}_lp.sdc

echo "=== LOW POWER: done ==="
echo "  Check: $REPORTS_DIR/power_lp.rpt"
echo "  Check: $REPORTS_DIR/timing_lp.rpt"

# --------------------------------------------------------------------------
# DESIGN POINT B: HIGH SPEED (tight 8 ns timing, optimize for performance)
# --------------------------------------------------------------------------
echo "=== DESIGN POINT B: HIGH SPEED SYNTHESIS ==="

# Re-elaborate for high-speed run
elaborate $DESIGN_NAME
link
current_design $DESIGN_NAME

# Tight clock constraint
create_clock -period 8.0 -name clk_hs [get_ports clk]
set_clock_uncertainty 0.15 [get_clocks clk_hs]
set_input_delay  1.5 -clock clk_hs [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1.5 -clock clk_hs [all_outputs]

compile_ultra -no_autoungroup -gate_clock -timing_high_effort_script

# Write reports for high speed point
report_timing  -nworst 5 -delay_type max > $REPORTS_DIR/timing_hs.rpt
report_area                              > $REPORTS_DIR/area_hs.rpt
report_power   -analysis_effort high     > $REPORTS_DIR/power_hs.rpt
report_qor                               > $REPORTS_DIR/qor_hs.rpt
report_constraint -all_violators         > $REPORTS_DIR/constraints_hs.rpt

# Write netlist
write_file -format verilog -hierarchy -output $OUTPUTS_DIR/${DESIGN_NAME}_hs.v
write_sdc  -nosplit $OUTPUTS_DIR/${DESIGN_NAME}_hs.sdc
write_sdf  -version 3.0 $OUTPUTS_DIR/${DESIGN_NAME}_hs.sdf

echo "=== HIGH SPEED: done ==="
echo "  Check: $REPORTS_DIR/power_hs.rpt"
echo "  Check: $REPORTS_DIR/timing_hs.rpt"

# --------------------------------------------------------------------------
# 5. PPA comparison summary
# --------------------------------------------------------------------------
echo ""
echo "============================================================"
echo "  PPA COMPARISON SUMMARY"
echo "  See reports/ directory for full detail"
echo "  LOW POWER  -> timing_lp.rpt, area_lp.rpt, power_lp.rpt"
echo "  HIGH SPEED -> timing_hs.rpt, area_hs.rpt, power_hs.rpt"
echo "============================================================"

exit
