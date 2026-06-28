set DESIGN   "static_pg_top"
set NETLIST  "./netlists/baseline/static_pg_top_lp.v"
set SDC_FILE "./netlists/baseline/static_pg_top_lp.sdc"
set RPT_DIR  "./reports/icc2_baseline"
set OUT_DIR  "./outputs"

set TECH_NDM "/usr/synopsys/saed/stdcell_lvt/ndm/tech_ndm/1p9m_tech.ndm"
set REF_NDM  "/usr/synopsys/saed/stdcell_lvt/ndm/saed14lvt_frame_timing_ccs.ndm"

file mkdir $RPT_DIR
file mkdir $OUT_DIR
file delete -force ${DESIGN}_icc2.dlib

create_lib ${DESIGN}_icc2.dlib \
    -ref_libs [list $TECH_NDM $REF_NDM]

read_verilog -design $DESIGN $NETLIST
link_design  $DESIGN
read_sdc     $SDC_FILE

initialize_floorplan \
    -boundary {{0 0} {30 30}} \
    -core_offset 2

create_net -power  VDD
create_net -ground VSS
connect_pg_net -automatic

# NOTE: clock_opt/route_opt are intentionally omitted here — confirmed on
# the proposed design that both fail with "Scenario Manager creation
# failed" (OPT-041) because this SAED14LVT package has no RC/parasitic
# (TLUplus) data, which every timing-driven ICC2 optimizer requires.
# create_placement is the one command in this flow that runs in a
# non-timing-driven mode and succeeds without it.
create_placement
report_timing  -max_paths 5          > $RPT_DIR/timing_place.rpt
report_utilization                   > $RPT_DIR/area_place.rpt
catch { report_power   -analysis_effort high > $RPT_DIR/power_place.rpt }

save_lib

puts "\n=== BASELINE ICC2 PLACEMENT COMPLETE ==="
exit
