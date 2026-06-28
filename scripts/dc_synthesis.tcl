set DESIGN    "adaptive_pg_top"
set RTL_DIR   "./rtl"
set RPT_DIR   "./reports/proposed"
set NET_DIR   "./netlists/proposed"
set TARGET_LIB "/usr/synopsys/saed/stdcell_lvt/db_nldm/saed14lvt_tt0p8v25c.db"

file mkdir $RPT_DIR
file mkdir $NET_DIR
set link_library   [list "*" $TARGET_LIB]
set target_library $TARGET_LIB

analyze -format verilog [list \
    $RTL_DIR/alu_32bit.v \
    $RTL_DIR/activity_monitor.v \
    $RTL_DIR/hysteresis_predictor.v \
    $RTL_DIR/power_state_fsm.v \
    $RTL_DIR/sleep_controller.v \
    $RTL_DIR/isolation_ctrl.v \
    $RTL_DIR/adaptive_pg_top.v ]

puts "\n===== CORNER A: LOW POWER 5ns =====\n"
elaborate $DESIGN; link; current_design $DESIGN
create_clock -name clk -period 5.0 [get_ports clk]
set_input_delay  1.0 -clock clk [all_inputs]
set_output_delay 1.0 -clock clk [all_outputs]
set_max_fanout    8 [current_design]
set_max_transition 0.4 [current_design]
set_clock_gating_style -sequential_cell latch -minimum_bitwidth 3
insert_clock_gating
set_leakage_optimization true
compile_ultra -no_autoungroup
report_timing -path full -delay max -max_paths 5 > $RPT_DIR/timing_lp.rpt
report_area                                       > $RPT_DIR/area_lp.rpt
report_power  -analysis_effort high               > $RPT_DIR/power_lp.rpt
write -format verilog -hierarchy -output $NET_DIR/${DESIGN}_lp.v
write_sdc $NET_DIR/${DESIGN}_lp.sdc
puts "LP done."

puts "\n===== CORNER B: HIGH SPEED 2ns =====\n"
reset_design
analyze -format verilog [list \
    $RTL_DIR/alu_32bit.v \
    $RTL_DIR/activity_monitor.v \
    $RTL_DIR/hysteresis_predictor.v \
    $RTL_DIR/power_state_fsm.v \
    $RTL_DIR/sleep_controller.v \
    $RTL_DIR/isolation_ctrl.v \
    $RTL_DIR/adaptive_pg_top.v ]
elaborate $DESIGN; link; current_design $DESIGN
create_clock -name clk -period 2.0 [get_ports clk]
set_input_delay  0.4 -clock clk [all_inputs]
set_output_delay 0.4 -clock clk [all_outputs]
set_max_fanout    6 [current_design]
set_max_transition 0.3 [current_design]
set_clock_gating_style -sequential_cell latch -minimum_bitwidth 3
insert_clock_gating
compile_ultra -no_autoungroup -timing_high_effort_script
report_timing -path full -delay max -max_paths 5 > $RPT_DIR/timing_hs.rpt
report_area                                       > $RPT_DIR/area_hs.rpt
report_power  -analysis_effort high               > $RPT_DIR/power_hs.rpt
write -format verilog -hierarchy -output $NET_DIR/${DESIGN}_hs.v
write_sdc $NET_DIR/${DESIGN}_hs.sdc
puts "HS done."
puts "=== PROPOSED synthesis complete ==="
exit
