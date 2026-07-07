<div align="center">

# An Activity-Rate-Aware Hysteresis Controller for Lightweight Adaptive Power Gating in SoC Functional Blocks

**A comparator-based, non-machine-learning adaptive power-gating controller that eliminates
sleep/wake thrashing under bursty workloads — designed, simulated, synthesized, and
placed-and-routed end-to-end in a 14 nm standard-cell flow.**

Joud Thaher · Layan Salem
Supervised by Dr. Khader Mohammed
Department of Electrical and Computer Engineering, Birzeit University, Palestine

📄 [Read the paper](paper/paper.pdf) · 📁 [LaTeX source](paper/latex) · 🎞️ [Presentations](presentations)

</div>

---

## Contents

- [Overview](#overview)
- [The problem this solves](#the-problem-this-solves)
- [How it works](#how-it-works)
- [Results at a glance](#results-at-a-glance)
- [Repository structure](#repository-structure)
- [Reproducing the results](#reproducing-the-results)
- [Limitations](#limitations)
- [Citing this work](#citing-this-work)

---

## Overview

Power gating — cutting the supply to idle logic — is one of the most common leakage-reduction
techniques in modern SoC design. But the policy that decides *when* to gate is usually crude:
a fixed idle-cycle counter, blind to how that idle period arose. This project designs, builds,
and rigorously evaluates a lightweight alternative: a **hysteresis-based controller** that looks
at both idle duration *and* recent activity rate before deciding to sleep, so it stops
mistaking bursty traffic for genuine idleness.

Everything in this repository — RTL, testbenches, UPF power intent, synthesis and
place-and-route scripts, reports, and the final paper — reflects one complete, reproducible
design flow, evaluated against a fair, structurally identical baseline.

## The problem this solves

Conventional multi-level power-gating controllers decide when to sleep using **idle-cycle
count alone**. This has a well-known failure mode: a workload made of short, frequent bursts
separated by gaps that individually exceed the sleep-entry threshold will cause the controller
to repeatedly enter and exit sleep states — **thrashing** — even though the block is, in
aggregate, far from idle. Every entry/exit cycle costs wake-up latency, and in deep-submicron
designs, a rush-current penalty on reactivation. The leakage saved by a brief sleep can be
completely outweighed by the cost of waking up over and over again.

## How it works

The controller adds one core idea on top of a conventional multi-level sleep-mode design: a
**hysteresis predictor** that gates sleep-state entry on the *conjunction* of two signals
rather than one.

- **Idle-cycle count** — how long the block has been continuously idle.
- **Activity rate** — a 16-cycle rolling-window population count, computed with nothing but
  shift registers and comparators (no multipliers, no learned model).

Sleep entry requires *both* conditions to indicate genuine idleness. When the activity rate
signals a sustained high duty cycle (`rate > HIGH_RATE_THRESH = 192/255`), the entry thresholds
widen by a fixed offset (`ADAPT_OFFSET = 6` cycles), actively suppressing sleep entry during
bursty-but-busy operation. Separate, narrower exit thresholds create the hysteresis band that
prevents oscillation between states.

To make the comparison fair, a **fixed-threshold baseline** — Agarwal et al.'s idle-count-only
policy — was built via single-module substitution: every other block (32-bit ALU, activity
monitor, power-state FSM, sleep controller, isolation controller, UPF power intent) is shared,
unmodified, between the two designs. The sleep-entry predictor is the *only* variable.

See [`figures/`](figures) for the architecture diagram, power-state FSM, gate-level schematics
of both predictors, and post-route layout views — and the [paper](paper/paper.pdf) for the full
write-up.

## Results at a glance

**Functional comparison** — RTL simulation, Synopsys VCS (T-2022.06-SP2), three synthetic
workloads (burst, sparse, mixed), identical stimulus to both designs:

| Workload | Metric              | Baseline | Proposed             |
|----------|----------------------|:--------:|:---------------------:|
| Burst    | Mode transitions     | 19       | **0**                 |
| Burst    | Throughput           | 19.3%    | **59.3%** (3.1× ↑)    |
| Sparse   | Mode transitions     | 26       | 23                     |
| Sparse   | Leakage saving       | 33.4%    | 31.6%                  |
| Mixed    | Mode transitions     | 20       | 17                      |
| Mixed    | Throughput           | 38.3%    | 38.8%                   |

Zero output mismatches were recorded across every workload — the substitution introduces no
functional regression in the shared datapath.

**Physical implementation** — Design Compiler Ultra (R-2020.09-SP5) synthesis, Fusion Compiler
(U-2022.12-SP5) place-and-route, SAED14LVT 14 nm standard-cell library:

| Metric                          | Baseline    | Proposed    | Overhead    |
|----------------------------------|:-----------:|:-----------:|:-----------:|
| DC synthesis area, LP (5 ns)     | 350.98 µm²  | 422.51 µm²  | +20.4%      |
| DC synthesis area, HS (2 ns)     | 351.25 µm²  | 442.76 µm²  | +26.1%      |
| **Post-route area (LP, real)**   | 361.50 µm²  | 410.61 µm²  | **+13.6%**  |
| Post-route standard-cell instances | 1,014     | 1,118       | +10.3%      |
| Post-route static leakage        | 115,164 pW  | 138,428 pW  | +20.2%      |
| Post-route worst negative slack (LP) | +3.25 ns | +3.25 ns  | **MET, both** |

Post-route layout: 30×30 µm² die, 45.83% core utilization, 9,873 µm total wire length,
**zero open nets**, timing fully closed at both the low-power (5 ns) and high-speed (2 ns)
corners.

**The headline trade-off:** a real, measured 13.6% area cost buys a 3.1× throughput
improvement under bursty traffic and zero mode transitions instead of nineteen — with leakage
savings under genuinely idle conditions staying within 1.8 percentage points of the baseline.
Full tables, gate-level breakdowns, and power decomposition are in the paper.

## Repository structure

```
├── rtl/                      Verilog RTL — ALU, activity monitor, hysteresis and
│                             fixed-threshold predictors, power-state FSM, sleep
│                             controller, isolation controller, and both top-level
│                             integrations (baseline + proposed)
├── tb/                       Testbenches — functional regression and baseline-vs-
│                             proposed comparison harness
├── upf/                      UPF power intent (PD_ALU / PD_TOP power domains)
├── filelist.f                VCS source file list
├── Makefile                  Simulation build targets — run `make help`
│
├── scripts/                  Synthesis and place-and-route Tcl scripts
│   ├── dc_synthesis.tcl       Design Compiler — proposed design, both corners
│   ├── dc_baseline.tcl        Design Compiler — baseline design, both corners
│   ├── icc2_place_route.tcl   Fusion Compiler — proposed design place-and-route
│   └── icc2_baseline_full_pr.tcl  Fusion Compiler — baseline place-and-route
│
├── netlists/                 Post-synthesis netlists + SDC, baseline vs proposed,
│                             low-power (LP) and high-speed (HS) corners
├── outputs/                  Final post-route netlists + SDC
│
├── reports/
│   ├── synthesis/             DC timing, area, and power reports (baseline, proposed)
│   └── place_and_route/       Fusion Compiler timing, area, and QoR reports
│
├── logs/                     Raw tool-run transcripts backing every report above
│
├── figures/                  All figures used in the paper: architecture diagram,
│                             power-state FSM, gate-level predictor schematics,
│                             post-route layouts, waveforms, and results charts
│
├── paper/
│   ├── paper.pdf              The final paper
│   └── latex/                 Full LaTeX source
│
├── presentations/
│   ├── midterm/                Midterm presentation
│   └── final/                  Final presentation
│
└── docs/
    ├── resources-plan.md       Course learning/onboarding plan
    └── process/                Milestone deliverables tracing the project's evolution
```

## Reproducing the results

Reproducing the physical-design results requires a Synopsys license (VCS, Design Compiler,
Fusion Compiler) and the SAED14LVT standard-cell library. **Neither is included in this
repository** — the library is a licensed PDK and must come from your own institution or
foundry access.

**Functional simulation:**
```bash
make help              # list all available targets
make sim_adaptive       # compile + run regression on the proposed design
make sim_comparison     # compile + run baseline vs. proposed comparison
```

**Synthesis and place-and-route** (from a Synopsys shell, with library paths configured
for your environment):
```bash
dc_shell -f scripts/dc_synthesis.tcl
dc_shell -f scripts/dc_baseline.tcl
icc2_shell -f scripts/icc2_place_route.tcl
icc2_shell -f scripts/icc2_baseline_full_pr.tcl
```

Reports land in `reports/synthesis/` and `reports/place_and_route/`, reproducing every number
in the results tables above.

## Limitations

Documented in full in the paper's Discussion section:

- Energy comparisons use a derived metric — transitions weighted by maximum wake-up latency —
  rather than first-principles joule measurement. A SPICE-level or annotated-switching-activity
  power simulation would strengthen this further.
- Post-route physical results are reported at a single (LP) corner; multi-corner PVT analysis
  was outside this project's scope.
- The burst/sparse/mixed workloads are synthetic, designed specifically to probe
  threshold-crossing behavior — not drawn from a real application trace.
- DRC verification was limited by the available PDK configuration in the course environment;
  reported spacing violations reflect missing DRC deck rules, not functional design errors.

## Citing this work

```
J. Thaher and L. Salem, "An Activity-Rate-Aware Hysteresis Controller for Lightweight
Adaptive Power Gating in SoC Functional Blocks," course project, Department of Electrical
and Computer Engineering, Birzeit University, 2026. Supervisor: Dr. Khader Mohammed.
Code: https://github.com/JHT127/hysteresis-adaptive-power-gating
```
