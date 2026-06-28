# =============================================================================
# File        : icc_place_route.tcl
# Tool        : Synopsys IC Compiler (ICC)
# Description : Place and Route script for the Adaptive Power Gating Controller.
#               Covers: floorplan, placement, clock tree synthesis (CTS),
#               routing, and post-layout power/timing analysis.
#
# Usage       : icc_shell -f scripts/icc_place_route.tcl | tee reports/icc_run.log
# NOTE        : Adjust library/technology paths for your PDK installation
# =============================================================================

# --------------------------------------------------------------------------
# 0. Setup variables
# --------------------------------------------------------------------------
set DESIGN_NAME  "adaptive_pg_top"
set NETLIST_DIR  "../netlists"
set REPORTS_DIR  "../reports/icc"
set OUTPUTS_DIR  "../outputs"
set UPF_FILE     "../upf/adaptive_pg.upf"

# Technology library (replace with your PDK):
set MW_LIB_PATH  "/path/to/mw/library"     ;# Milkyway library path
set TF_FILE      "/path/to/tech/tech.tf"    ;# Technology file
set MAP_FILE     "/path/to/tech/tf.map"     ;# Tluplus map
set MAX_TLUPLUS  "/path/to/tluplus/maxTLU.tluplus"
set MIN_TLUPLUS  "/path/to/tluplus/minTLU.tluplus"

file mkdir $REPORTS_DIR
file mkdir $OUTPUTS_DIR

# --------------------------------------------------------------------------
# 1. Create Milkyway design library and read netlist
# --------------------------------------------------------------------------
create_mw_lib -technology $TF_FILE \
              -mw_reference_library $MW_LIB_PATH \
              ${DESIGN_NAME}_mwlib

open_mw_lib ${DESIGN_NAME}_mwlib

import_designs $NETLIST_DIR/${DESIGN_NAME}_lp.v \
    -format verilog \
    -top $DESIGN_NAME

read_sdc $NETLIST_DIR/${DESIGN_NAME}_lp.sdc

# Load UPF for power-domain-aware P&R
# load_upf $UPF_FILE   ;# Uncomment if UPF-aware ICC flow available

# RC parasitics
set_tlu_plus_files \
    -max_tluplus $MAX_TLUPLUS \
    -min_tluplus $MIN_TLUPLUS \
    -tech2itf_map $MAP_FILE

# --------------------------------------------------------------------------
# 2. Floorplan
# --------------------------------------------------------------------------
# Aspect ratio 1:1 (square), 70% core utilization
initialize_floorplan \
    -layout_style standard_cell_row \
    -core_utilization_ratio 0.70 \
    -row_core_ratio 1.0 \
    -left_io2core  5.0 \
    -right_io2core 5.0 \
    -bottom_io2core 5.0 \
    -top_io2core 5.0

# Power rings around core
create_rectangular_rings \
    -nets {VDD VSS} \
    -left_offset 2 -left_segment_width 1 \
    -right_offset 2 -right_segment_width 1 \
    -top_offset 2 -top_segment_width 1 \
    -bottom_offset 2 -bottom_segment_width 1

# Power stripes
create_power_straps \
    -direction horizontal \
    -start_at 10 \
    -pitch 20 \
    -width 1 \
    -nets {VDD VSS}

# --------------------------------------------------------------------------
# 3. Power domain physical partitioning
# Assign PD_ALU region to contain u_alu instance
# --------------------------------------------------------------------------
create_voltage_area \
    -name PD_ALU_AREA \
    -coordinate { {10 10} {50 50} } \
    -guard_band_x 2 -guard_band_y 2

# --------------------------------------------------------------------------
# 4. Placement
# --------------------------------------------------------------------------
set_congestion_options -max_util 0.80
place_opt -area_recovery -effort high

# Check placement quality
report_placement_utilization > $REPORTS_DIR/placement_utilization.rpt

# --------------------------------------------------------------------------
# 5. Clock Tree Synthesis (CTS)
# --------------------------------------------------------------------------
set_clock_tree_options \
    -target_skew 0.1 \
    -target_max_transition 0.15

clock_opt -only_cts -effort high

# CTS reports
report_clock_tree -summary   > $REPORTS_DIR/cts_summary.rpt
report_clock_tree -settings  > $REPORTS_DIR/cts_settings.rpt

# --------------------------------------------------------------------------
# 6. Post-CTS optimization
# --------------------------------------------------------------------------
clock_opt -only_psyn

# --------------------------------------------------------------------------
# 7. Routing
# --------------------------------------------------------------------------
set_app_var route_opt_effort high
route_opt -initial_route_only
route_opt -skip_initial_route -effort high

# Check routing DRC
verify_route > $REPORTS_DIR/route_drc.rpt

# --------------------------------------------------------------------------
# 8. Post-layout timing analysis
# --------------------------------------------------------------------------
report_timing \
    -nworst 10 \
    -delay_type max \
    -nets \
    -input_pins \
    > $REPORTS_DIR/timing_postlayout.rpt

report_timing \
    -nworst 10 \
    -delay_type min \
    > $REPORTS_DIR/hold_postlayout.rpt

# --------------------------------------------------------------------------
# 9. Post-layout power analysis
# --------------------------------------------------------------------------
# Use switching activity from VCD (generated by testbench)
read_vcd ../tb/tb_adaptive_pg_top.vcd \
    -strip_path tb_adaptive_pg_top/dut

report_power \
    -analysis_effort high \
    -include_hierarchical_results \
    > $REPORTS_DIR/power_postlayout.rpt

# --------------------------------------------------------------------------
# 10. Final outputs
# --------------------------------------------------------------------------
# GDSII
write_gds -merge_files $MW_LIB_PATH \
    -output $OUTPUTS_DIR/${DESIGN_NAME}.gds

# Post-layout netlist
write_verilog $OUTPUTS_DIR/${DESIGN_NAME}_final.v

# Timing constraints
write_sdc -nosplit $OUTPUTS_DIR/${DESIGN_NAME}_final.sdc

# SPEF parasitics (for signoff power/timing)
write_parasitics \
    -format SPEF \
    -output $OUTPUTS_DIR/${DESIGN_NAME}.spef

echo ""
echo "==========================================================="
echo "  ICC PLACE & ROUTE COMPLETE"
echo "  Post-layout reports in: $REPORTS_DIR/"
echo "  Final outputs    in:    $OUTPUTS_DIR/"
echo "==========================================================="

exit
