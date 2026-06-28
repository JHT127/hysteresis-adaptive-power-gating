VCS       = vcs -sverilog -full64 -debug_access+all -timescale=1ns/1ps
FLIST     = filelist.f
SIMOUT    = sim_out

.PHONY: all sim_adaptive sim_comparison compile_adaptive compile_comparison clean help

all: sim_adaptive sim_comparison

help:
	@echo "Targets:"
	@echo "  make compile_adaptive   - compile only, no run: tb_adaptive_pg_top.v"
	@echo "  make compile_comparison - compile only, no run: tb_comparison.v"
	@echo "  make sim_adaptive       - compile + run: regression on adaptive design alone"
	@echo "  make sim_comparison     - compile + run: baseline vs proposed PPA table"
	@echo "  make clean              - remove all VCS build artifacts and sim_out logs"

$(SIMOUT):
	mkdir -p $(SIMOUT)

# -----------------------------------------------------------------------------
# Compile-only targets — elaborate and link, don't execute. Use these to
# check a fresh RTL/TB edit compiles before spending time on a full run.
# -----------------------------------------------------------------------------
compile_adaptive: $(SIMOUT)
	$(VCS) -f $(FLIST) tb/tb_adaptive_pg_top.v \
		-l $(SIMOUT)/vcs_compile_adaptive.log -o simv_adaptive

compile_comparison: $(SIMOUT)
	$(VCS) -f $(FLIST) tb/tb_comparison.v \
		-l $(SIMOUT)/vcs_compile_comparison.log -o simv_comparison

# -----------------------------------------------------------------------------
# Compile + run targets — depend on the compile-only targets above, so the
# vcs command itself is defined in exactly one place.
# -----------------------------------------------------------------------------
sim_adaptive: compile_adaptive
	./simv_adaptive -l $(SIMOUT)/vcs_sim_adaptive.log

sim_comparison: compile_comparison
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
