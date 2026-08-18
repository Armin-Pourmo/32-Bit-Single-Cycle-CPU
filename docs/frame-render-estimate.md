# For fun: how long would this CPU take to render one AAA game frame?

Not a serious performance claim — a back-of-envelope Fermi estimate comparing this single-cycle educational CPU to an RTX 5090, done because it seemed like a fun way to make the scale of the gap tangible. Every number below is tagged **[measured]** (produced ourselves, using the real synthesis/place-and-route toolchain against this repo's actual RTL), **[published]** (from a cited external source), or **[assumed]** (a reasoned guess — there's no way to pin this down further without changing the scope of the exercise).

## 1. GPU side — RTX 5090 + Cyberpunk 2077

- **[published]** RTX 5090: 21,760 CUDA cores, 2.41 GHz boost, **~104.8 TFLOPS FP32**.
  Sources: [RunPod](https://www.runpod.io/articles/guides/nvidia-rtx-5090),
  [Flopper.io](https://flopper.io/gpu/nvidia-geforce-rtx-5090-32gb/spec-sheet)
- **[published]** Cyberpunk 2077, 1440p, **Ultra preset, ray tracing OFF, no DLSS/FSR
  (native)**: **190 fps** → 5.26 ms/frame. Source:
  [KitGuru RTX 5090 review](https://www.kitguru.net/components/graphic-cards/dominic-moass/nvidia-rtx-5090-review-ray-tracing-dlss-4-and-raw-power-explored/all/1/)

  **Why 1440p and not 1080p:** real 1080p benchmarks for the 5090 in this game are
  actually **CPU-bottlenecked** (the *test rig's* CPU, not the GPU) — several reviews
  note the 5090 performs about the same as a 4090 at 1080p for exactly this reason.
  That makes 1080p numbers useless for isolating GPU compute capability. 1440p Ultra
  (no RT) is still clearly GPU-bound, so we use that as a stand-in. The real 1080p
  GPU-only frame time would be *shorter* than 5.26 ms, so this choice is conservative
  in the CPU's favor — if anything it understates how far ahead the GPU really is.

- **[assumed]** Real games rarely sustain peak shader throughput (memory bandwidth,
  branching, fixed-function units doing part of the work). Assume **~30% of peak**
  is actually delivered as useful compute during a frame. This is the single biggest
  assumption in this whole exercise and no published benchmark gives you this number
  directly — treat the final result as order-of-magnitude, not precise.

**Compute per frame** ≈ 104.8×10¹² × 0.30 × 0.00526 s ≈ **1.65×10¹¹ FLOP** (~165 GFLOP)

## 2. CPU side — real synthesis + place-and-route

**[measured]** Ran the actual toolchain (Yosys + nextpnr, from the [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build)) against this CPU's real RTL, targeting a real, cheap FPGA (Lattice iCE40 UP5K):

```
synth_ice40  ->  nextpnr-ice40  ->  icetime (independent cross-check)

nextpnr-ice40:  Max frequency for clock 'clk': 9.66 MHz (placement estimate)
                Max frequency for clock 'clk': 9.80 MHz (final, post-route)
icetime:        Timing estimate: 110.32 ns (9.06 MHz)   (independent static analysis)
```

The two tools agree closely (9.06–9.80 MHz) — good cross-validation. Using
**~9.4 MHz** as a representative figure.

Methodology notes, in the spirit of this project's other disclosures:
- The design's `data_memory` (a 64KB array) was swapped for a tiny placeholder
  register for this run — a real chip would put 64KB in a dedicated SRAM/BRAM macro,
  not general logic, and it isn't part of the CPU's own critical path anyway. Same
  reasoning already used for the gate-count synthesis elsewhere in this repo.
- The CPU's four 32-bit debug (`TEST_*`) ports were XOR-reduced to 1 bit for this
  run only, via a scratch-only wrapper — those ports exist purely for testbench
  visibility and were never meant to be real I/O; without reducing them, a small
  FPGA package doesn't have anywhere near enough physical pins to route to.
- Looking at the critical path report, a meaningful chunk of the ~110 ns delay is
  routing (`Span4Mux`/`LocalMux` interconnect hops), not raw logic depth — typical
  of a fully automatic, unconstrained placement with no floorplanning. A careful
  manual placement pass could plausibly do better. Take 9.4 MHz as "what you get
  with zero tuning effort," not a hard ceiling.
- This is an **FPGA** number. The same RTL pushed through a real ASIC process would
  very likely clock several to dozens of times higher — FPGAs are inherently much
  slower than custom silicon for equivalent logic. If you care about "what's the
  fastest this could ever go," FPGA Fmax is a floor, not the answer.

**[measured]** IPC = exactly 1 (single-cycle datapath, by construction — no
pipelining, no stalls beyond the obvious).

**[assumed]** No multiply/divide instruction and no FPU exist in this ISA at all —
only add/sub/shift/logic. A software float multiply-add (shift-add integer multiply
loop, plus exponent/mantissa handling) plausibly costs **~150 instructions**
(a reasoned estimate, not a measured one — getting a real number here would mean
hand-assembling and simulating an actual software float routine on this CPU, which
is a natural next step if this estimate is ever revisited).

**Effective CPU throughput** ≈ 9.4×10⁶ Hz ÷ 150 ≈ **~62,700 FLOP/s**

## 3. Putting it together

```
GPU effective rate  ≈ 104.8e12 × 0.30            ≈ 3.14×10¹³ FLOP/s
CPU effective rate  ≈ 9.4e6 / 150                ≈ 6.27×10⁴ FLOP/s
ratio               ≈ 3.14e13 / 6.27e4            ≈ ~5.0×10⁸  (500 million times slower)

CPU frame time ≈ 5.26 ms × 5.0×10⁸ ≈ 2.63×10⁶ s ≈ ~30.5 days for one frame
```

## Sensitivity — how much does this move if the assumptions shift?

The two **[assumed]** inputs (GPU utilization %, instructions-per-software-FLOP) are
the only real slack left; both **[measured]**/**[published]** inputs are solid.

| Instructions per float op | CPU frame time |
|---|---|
| 100 (optimistic emulation) | ~20 days |
| 150 (this estimate)        | ~30.5 days |
| 300 (pessimistic)          | ~61 days |

GPU utilization moves the answer linearly the same way (half the assumed 30% →
roughly double the frame time, and vice versa).

## Headline

Somewhere in the ballpark of **2–8 weeks per frame**, most plausibly ~1 month,
to render one frame of a modern AAA game at settings a real GPU clears in ~5 ms.
The dominant reason isn't clock speed (measured at a real ~9.4 MHz on a real cheap
FPGA) — it's the complete absence of hardware multiply/divide/floating point,
forcing every meaningful math operation through a 100+ instruction software loop
on a scalar, single-issue core, compared to a chip with tens of thousands of
parallel FP32 lanes purpose-built for exactly this workload.
