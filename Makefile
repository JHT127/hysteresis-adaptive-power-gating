VCS       = vcs -sverilog -full64 -debug_access+all -timescale=1ns/1ps
FLIST     = filelist.f
SIMOUT    = sim_out

.PHONY: all sim_adaptive sim_comparison clean help

all: sim_adaptive sim_comparison

help:
	@echo "Targets:"
	@echo "  make sim_adaptive    - regression: tb_adaptive_pg_top.v (adaptive design only)"
	@echo "  make sim_comparison  - baseline vs proposed: tb_comparison.v"
	@echo "  make clean           - remove all VCS build artifacts and sim_out logs"

$(SIMOUT):
	mkdir -p $(SIMOUT)

# -----------------------------------------------------------------------------
# Regression: adaptive design alone, 5-workload testbench (unchanged from the
# Current System Audit — re-run this after any RTL edit to confirm no
# regression before trusting comparison results).
# -----------------------------------------------------------------------------
sim_adaptive: $(SIMOUT)
	$(VCS) -f $(FLIST) tb/tb_adaptive_pg_top.v \
		-l $(SIMOUT)/vcs_compile_adaptive.log -o simv_adaptive
	./simv_adaptive -l $(SIMOUT)/vcs_sim_adaptive.log

# -----------------------------------------------------------------------------
# Head-to-head: static_pg_top (baseline) vs adaptive_pg_top (proposed),
# identical stimulus, side-by-side PPA table — this is the Step 5 driver.
# -----------------------------------------------------------------------------
sim_comparison: $(SIMOUT)
	$(VCS) -f $(FLIST) tb/tb_comparison.v \
		-l $(SIMOUT)/vcs_compile_comparison.log -o simv_comparison
	./simv_comparison -l $(SIMOUT)/vcs_sim_comparison.log

# -----------------------------------------------------------------------------
# Clean all regenerable VCS artifacts (mirrors the repo's .gitignore so
# nothing here should ever be committed).
# -----------------------------------------------------------------------------
clean:
	rm -rf simv_adaptive simv_adaptive.daidir
	rm -rf simv_comparison simv_comparison.daidir
	rm -rf csrc ucli.key *.vcd *.vpd DVEfiles
	rm -f $(SIMOUT)/*.log
