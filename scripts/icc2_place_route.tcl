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

# FIX (parasitics, corrected): set_tlu_plus_files is an ICC1/DC command and
# doesn't exist in ICC2 (confirmed via `man`). ICC2's real two-step sequence:
# (1) read_parasitic_tech loads the TLUplus data into the library under a
#     named model; (2) set_parasitic_parameters attaches that named model to
#     the active constraint corner for RC extraction. Both confirmed via
#     `man read_parasitic_tech` / `man set_parasitic_parameters`.
read_parasitic_tech \
    -tlup /usr/synopsys/saed/tech/star_rc/max/saed14nm_1p9m_Cmax.tluplus \
    -layermap /usr/synopsys/saed/tech/star_rc/saed14nm_tf_itf_tluplus.map \
    -name saed14lvt_max

read_parasitic_tech \
    -tlup /usr/synopsys/saed/tech/star_rc/min/saed14nm_1p9m_Cmin.tluplus \
    -layermap /usr/synopsys/saed/tech/star_rc/saed14nm_tf_itf_tluplus.map \
    -name saed14lvt_min

set_parasitic_parameters \
    -early_spec saed14lvt_min \
    -late_spec  saed14lvt_max

initialize_floorplan \
    -boundary {{0 0} {30 30}} \
    -core_offset 2

create_net -power  VDD
create_net -ground VSS
connect_pg_net -automatic

place_opt
report_timing  -max_paths 5          > $RPT_DIR/timing_place.rpt
catch { report_power   -analysis_effort high > $RPT_DIR/power_place.rpt }

clock_opt
report_clock_qor                     > $RPT_DIR/clock_qor.rpt
report_timing  -max_paths 5          > $RPT_DIR/timing_cts.rpt

route_opt
report_timing  -max_paths 10         > $RPT_DIR/timing_postroute.rpt
report_utilization                   > $RPT_DIR/area_postroute.rpt
catch { report_power   -analysis_effort high > $RPT_DIR/power_postroute.rpt }

write_verilog  $OUT_DIR/${DESIGN}_postroute.v
write_sdc      -output $OUT_DIR/${DESIGN}_postroute.sdc
save_lib

puts "\n=== ICC2 COMPLETE ==="
exit
