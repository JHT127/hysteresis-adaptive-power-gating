# Activity-Rate-Aware Hysteresis Controller for Lightweight Adaptive Power Gating

A lightweight, non-machine-learning adaptive power-gating controller for a small SoC
functional block (32-bit ALU), designed to eliminate sleep/wake **thrashing** under
bursty workloads — implemented end-to-end from RTL through synthesis and place-and-route
in a 14 nm standard-cell flow.

> Course project — Department of Electrical and Computer Engineering, Birzeit University
> **Authors:** Joud Thaher, Layan Salem
> **Supervisor:** Dr. Khader Mohammed
> **Paper:** _link added once the final draft is ready_

---

## The problem

Conventional multi-level power-gating controllers decide when to sleep using **idle-cycle
count alone**. Under bursty traffic — frequent short idle gaps that individually exceed the
sleep-entry threshold — this causes the controller to repeatedly enter and exit sleep
states ("thrashing"), where the wake-up latency cost outweighs the leakage saved.

## This project's approach

A **hysteresis predictor** gates sleep-state entry on the *conjunction* of two conditions:
consecutive idle-cycle count **and** a 16-cycle rolling-window activity rate. When recent
activity indicates a bursty (rather than genuinely idle) workload, entry thresholds are
adaptively widened to suppress unnecessary sleep entry — using only shift-register
population-count logic and comparators, no multipliers and no learned model.

To isolate this as the sole experimental variable, a **fixed-threshold baseline**
(idle-cycle-count-only policy, representative of prior work) shares every other module —
ALU, activity monitor, power-state FSM, sleep controller, isolation controller, and UPF
power intent — unmodified with the proposed design.

## Results summary

| Workload | Baseline (fixed-threshold) | Proposed (hysteresis) |
|---|---|---|
| Burst — mode transitions | 19 | **0** |
| Burst — throughput | 19.3% | **59.3%** (3.1× improvement) |
| Sparse — leakage savings | 33.4% | 31.6% (comparable) |
| Post-route area (µm²) | 361.50 | 410.61 (+13.6%) |
| Timing closure (both corners) | MET | MET |

Full methodology, workload definitions, and discussion are in [`paper/`](paper/).

## Repository structure

```
├── rtl/                    RTL: ALU, activity monitor, hysteresis & fixed-threshold
│                           predictors, power-state FSM, sleep controller, isolation
│                           controller, and both top-level integrations
├── tb/                     Testbenches (regression + baseline-vs-proposed comparison)
├── upf/                    UPF power intent (PD_ALU / PD_TOP power domains)
├── scripts/                Design Compiler (dc_*.tcl) and IC Compiler II
│                           (icc2_*.tcl) synthesis / place-and-route scripts
├── filelist.f, Makefile    VCS compile/simulate targets (see `make help`)
├── netlists/               Post-synthesis netlists, baseline vs proposed, LP/HS corners
├── outputs/                Final post-route netlists + SDC
├── reports/
│   ├── synthesis/          DC timing/area/power reports (baseline, proposed)
│   └── place_and_route/    ICC2 timing/area/power/QoR reports (baseline, proposed)
├── logs/                   Raw tool-run transcripts backing the reports above
├── figures/                Architecture, FSM, layout, and waveform figures
├── paper/                  Paper draft (LaTeX source once finalized)
├── presentations/          Milestone and midterm presentations
└── docs/                   Course-process documentation and reference list
```

## Reproducing the results

Requires a Synopsys license (VCS, Design Compiler, IC Compiler II) and the SAED14LVT
standard-cell library — **not included** in this repo (licensed PDK, must be provided
by your own institution/foundry access).

```bash
# RTL simulation (functional regression + baseline-vs-proposed comparison)
make help              # list all targets
make sim_adaptive       # compile + run regression on the proposed design
make sim_comparison      # compile + run baseline vs proposed PPA comparison

# Synthesis and place-and-route
# (run from a Synopsys shell with DC/ICC2 licensed and library paths configured)
dc_shell -f scripts/dc_synthesis.tcl
dc_shell -f scripts/dc_baseline.tcl
icc2_shell -f scripts/icc2_place_route.tcl
icc2_shell -f scripts/icc2_baseline_full_pr.tcl
```

Generated reports land in `reports/`, and the results in the table above can be
reproduced directly from `reports/synthesis/` and `reports/place_and_route/`.

## Citing this work

If you use this design or comparison methodology, please cite the paper (link above)
once available. See [`docs/REFERENCES.md`](docs/REFERENCES.md) for the prior work this
project builds on and compares against.

## License

See [`LICENSE`](LICENSE).
