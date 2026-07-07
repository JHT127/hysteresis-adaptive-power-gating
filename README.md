# Activity-Rate-Aware Hysteresis Controller for Lightweight Adaptive Power Gating in SoC Functional Blocks

A lightweight, non-machine-learning adaptive power-gating controller for a small SoC
functional block (32-bit ALU), designed to eliminate sleep/wake **thrashing** under
bursty workloads — implemented end-to-end from RTL through synthesis and place-and-route
in a 14 nm standard-cell flow.

> Course project — Department of Electrical and Computer Engineering, Birzeit University, Palestine
> **Authors:** Joud Thaher, Layan Salem
> **Supervisor:** Dr. Khader Mohammed
> **Paper:** [`paper/paper_final.pdf`](paper/paper_final.pdf)

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
adaptively widened (`ADAPT_OFFSET = 6` cycles above `HIGH_RATE_THRESH = 192/255`) to
suppress unnecessary sleep entry — using only shift-register population-count logic and
comparators, no multipliers and no learned model.

To isolate this as the sole experimental variable, a **fixed-threshold baseline**
(idle-cycle-count-only policy per Agarwal et al.) shares every other module — ALU, activity
monitor, power-state FSM, sleep controller, isolation controller, and UPF power intent —
unmodified with the proposed design.

## Results summary

**Functional comparison** (RTL simulation, VCS T-2022.06-SP2):

| Workload | Metric | Baseline | Proposed |
|---|---|---|---|
| Burst | Mode transitions | 19 | **0** |
| Burst | Throughput | 19.3% | **59.3%** (3.1×) |
| Sparse | Mode transitions | 26 | 23 |
| Sparse | Leakage saving | 33.4% | 31.6% |
| Mixed | Mode transitions | 20 | 17 |
| Mixed | Throughput | 38.3% | 38.8% |

Zero output mismatches across all workloads (functional correctness of the single-module
substitution confirmed).

**Physical implementation** (DC Ultra R-2020.09-SP5 synthesis; Fusion Compiler
U-2022.12-SP5 place-and-route; SAED14LVT):

| Metric | Baseline | Proposed | Overhead |
|---|---|---|---|
| DC synthesis area, LP (5 ns) | 350.98 µm² | 422.51 µm² | +20.4% |
| DC synthesis area, HS (2 ns) | 351.25 µm² | 442.76 µm² | +26.1% |
| **Post-route area (LP corner, real)** | 361.50 µm² | 410.61 µm² | **+13.6%** |
| Post-route instances | 1,014 | 1,118 | +10.3% |
| Post-route WNS (LP) | +3.25 ns | +3.25 ns | MET, both |
| Post-route static leakage | 115,164 pW | 138,428 pW | +20.2% |

Post-route layout: 30×30 µm² die, 45.83% core utilization, 9,873 µm total wire length,
**0 open nets**, timing fully met at both LP (5 ns) and HS (2 ns) corners.

Full methodology, workload definitions, gate-level schematics, and discussion of
limitations are in the [paper](paper/paper_final.pdf).

## Repository structure

```
├── rtl/                    RTL: ALU, activity monitor, hysteresis & fixed-threshold
│                           predictors, power-state FSM, sleep controller, isolation
│                           controller, and both top-level integrations
├── tb/                     Testbenches (regression + baseline-vs-proposed comparison)
├── upf/                    UPF power intent (PD_ALU / PD_TOP power domains)
├── scripts/                Design Compiler (dc_*.tcl) and Fusion Compiler
│                           (icc2_*.tcl) synthesis / place-and-route scripts
├── filelist.f, Makefile    VCS compile/simulate targets (see `make help`)
├── netlists/               Post-synthesis netlists, baseline vs proposed, LP/HS corners
├── outputs/                Final post-route netlists + SDC
├── reports/
│   ├── synthesis/          DC timing/area/power reports (baseline, proposed)
│   └── place_and_route/    Fusion Compiler timing/area/QoR reports (baseline, proposed)
├── logs/                   Raw tool-run transcripts backing the reports above
├── figures/                Architecture, FSM, gate-level, layout, and waveform figures
├── paper/
│   ├── paper_final.pdf     Final paper
│   └── latex/              LaTeX source
├── presentations/
│   ├── midterm/            Midterm presentation
│   └── final/               Final presentation
└── docs/                   Course-process documentation
```

## Reproducing the results

Requires a Synopsys license (VCS, Design Compiler, Fusion Compiler) and the SAED14LVT
standard-cell library — **not included** in this repo (licensed PDK, must be provided
by your own institution/foundry access).

```bash
# RTL simulation (functional regression + baseline-vs-proposed comparison)
make help              # list all targets
make sim_adaptive       # compile + run regression on the proposed design
make sim_comparison      # compile + run baseline vs proposed PPA comparison

# Synthesis and place-and-route
# (run from a Synopsys shell with DC/Fusion Compiler licensed and library paths configured)
dc_shell -f scripts/dc_synthesis.tcl
dc_shell -f scripts/dc_baseline.tcl
icc2_shell -f scripts/icc2_place_route.tcl
icc2_shell -f scripts/icc2_baseline_full_pr.tcl
```

Generated reports land in `reports/`, and the results in the tables above can be
reproduced directly from `reports/synthesis/` and `reports/place_and_route/`.

## Limitations (from the paper's Discussion section)

- Energy comparisons use a derived metric (transitions weighted by max wake-up latency),
  not first-principles joule measurement; SPICE-level or annotated-switching-activity
  power simulation would strengthen this further.
- Post-route results are reported at a single (LP) corner; multi-corner PVT analysis was
  outside this project's scope.
- Synthetic workloads (burst/sparse/mixed) are designed to probe threshold-crossing
  behavior specifically, not drawn from a real application trace.
- DRC verification was limited by the available PDK configuration on the server
  environment; the reported spacing violations reflect missing DRC deck rules, not
  functional errors.

## Citing this work

```
J. Thaher and L. Salem, "An Activity-Rate-Aware Hysteresis Controller for Lightweight
Adaptive Power Gating in SoC Functional Blocks," course project, Dept. of Electrical and
Computer Engineering, Birzeit University, 2026. Supervisor: Dr. Khader Mohammed.
Code: https://github.com/JHT127/hysteresis-adaptive-power-gating
```
