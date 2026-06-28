set DESIGN   "adaptive_pg_top"
set NETLIST  "./netlists/proposed/adaptive_pg_top_lp.v"
set SDC_FILE "./netlists/proposed/adaptive_pg_top_lp.sdc"
set RPT_DIR  "./reports/icc2"
set OUT_DIR  "./outputs"

set TECH_NDM "/usr/synopsys/saed/stdcell_lvt/ndm/tech_ndm/1p9m_tech.ndm"
set REF_NDM  "/usr/synopsys/saed/stdcell_lvt/ndm/saed14lvt_frame_timing_ccs.ndm"

file mkdir $RPT_DIR
file mkdir $OUT_DIR
file delete -force ${DESIGN}_icc2.dlib

create_lib ${DESIGN}_icc2.dlib \
    -ref_libs [list $TECH_NDM $REF_NDM]

# FIX (Phase 2): read_verilog has no -library option in ICC2 — the design
# library context is already established by create_lib above. The original
# "-library WORK" argument caused CMD-081 / SEL-005 and aborted the script
# before anything else ran.
read_verilog -design $DESIGN $NETLIST
link_design  $DESIGN
read_sdc     $SDC_FILE

initialize_floorplan \
    -boundary {{0 0} {30 30}} \
    -core_offset 2

create_net -power  VDD
create_net -ground VSS
create_pg_ring_pattern ring_pat \
    [list [list -net VDD -layer M8 -width 0.8] \
          [list -net VSS -layer M8 -width 0.8]]
set_pg_strategy ring_s -core \
    -pattern [list [list -pattern ring_pat -offset {0.5 0.5}]]
compile_pg -strategies ring_s

place_opt
report_timing  -max_paths 5          > $RPT_DIR/timing_place.rpt
report_power   -analysis_effort high > $RPT_DIR/power_place.rpt

clock_opt
report_clock_qor                     > $RPT_DIR/clock_qor.rpt
report_timing  -max_paths 5          > $RPT_DIR/timing_cts.rpt

route_opt
report_timing  -max_paths 10         > $RPT_DIR/timing_postroute.rpt
report_area                          > $RPT_DIR/area_postroute.rpt
report_power   -analysis_effort high > $RPT_DIR/power_postroute.rpt

write_verilog  $OUT_DIR/${DESIGN}_postroute.v
write_sdc      $OUT_DIR/${DESIGN}_postroute.sdc
save_lib

puts "\n=== ICC2 COMPLETE ==="
exit
