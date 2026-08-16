# Single-Cycle MIPS-Style CPU

A 32-bit, single-cycle MIPS-style CPU implemented from scratch in SystemVerilog — every instruction fetches, decodes, executes, accesses memory, and writes back within one clock edge. No pipelining, no hazard logic; the goal was to build and verify a complete, correct datapath and control unit from the gate level up.

![CPU Datapath](docs/MIPS%20CPU%2020206.svg)

<sub>*Diagram simplified for readability — a majority of the MCU and ALU Decoder control signals are omitted. See `CPU/src/MCU.sv` and `CPU/src/ALUDecoder.sv` for the complete control logic.*</sub>

## Status

The full instruction set below is implemented and passing. The top-level testbench (`CPU/tb/CPU_tb.sv`) runs a hand-written program through the CPU and checks 24 register/memory assertions, including a full `jal`/`jr` call-and-return round trip:

```
CPU testbench complete: 24 passed, 0 failed
ALL TESTS PASSED
```

## Instructions implemented

| Type | Instructions |
|---|---|
| R-type (ALU) | `add` `sub` `and` `or` `xor` `nor` `slt` `sll` `srl` `sra` |
| R-type (control) | `jr` |
| I-type (ALU/immediate) | `addi` `andi` `ori` `lui` |
| I-type (memory) | `lw` `sw` |
| I-type (branch) | `beq` `bne` |
| J-type | `j` `jal` |

## Instruction encoding

Every instruction is a 32-bit word in one of three formats, decoded by `Instruction_Unit/src/decoder_unit.sv`:

**R-type** — register-to-register ALU ops and `jr`

| Bits | 31–26 | 25–21 | 20–16 | 15–11 | 10–6 | 5–0 |
|---|---|---|---|---|---|---|
| Field | `opcode` | `rs` | `rt` | `rd` | `shamt` | `funct` |
| Meaning | always `000000` | source register 1 | source register 2 | destination register | shift amount (`sll`/`srl`/`sra`) | selects the ALU operation |

**I-type** — immediates, loads/stores, branches

| Bits | 31–26 | 25–21 | 20–16 | 15–0 |
|---|---|---|---|---|
| Field | `opcode` | `rs` | `rt` | `immediate` |
| Meaning | selects the operation | source register / base address register | destination register (or 2nd source for `beq`/`bne`/`sw`) | sign- or zero-extended constant, or memory/branch offset |

**J-type** — unconditional jumps

| Bits | 31–26 | 25–0 |
|---|---|---|
| Field | `opcode` | `address` |
| Meaning | selects `j` or `jal` | target instruction address, combined with `PC+4[31:28]` and shifted left 2 |

## Architecture

The CPU is built as independently-verified modules wired together in `CPU/src/CPU.sv`:

| Directory | Contents |
|---|---|
| `Instruction_Unit/` | PC register/update logic, PC+4, branch and jump target calculation, instruction memory, instruction decode |
| `ALU/` | ALU and its sub-units (add/subtract, logic, shift), plus the ALU opcode decoder |
| `Memory/` | Register file, data memory, sign/zero extender, write-back mux |
| `CPU/` | Top-level datapath wiring, the main control unit (MCU), and the ALU control decoder |

Control flow: the **Control Unit (MCU)** decodes `opcode`/`funct` into the control word (`RegDst`, `ALUSrc`, `MemToReg`, `RegWrite`, `MemWrite`, `Branch`, `BranchNE`, `Jump`, `ALUOp`, `ExtOp`, `LU`, `JAL`) that drives every mux and enable pin in the datapath. Two feedback loops close the datapath: the **next-PC mux** (selecting between `PC+4`, branch target, jump target, and the JR register value) feeds back into the PC register, and the **write-back mux** (selecting between ALU result, memory read data, `{imm,16'b0}` for LUI, and `PC+4` for JAL) feeds back into the register file. See the diagram above for the full wiring.

## Running the tests

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/).

```bash
# Top-level CPU testbench
iverilog -g2012 -o build/cpu_tb.out -s CPU_tb $(cat sources.f)
vvp build/cpu_tb.out
```

Individual module testbenches live alongside their sources in each `tb/` directory (e.g. `ALU/tb/alu_tb.sv`, `Memory/tb/bit_extender_tb.sv`) and can be compiled/run the same way against just their relevant source files.

`instructions.hex` is the program image loaded by `instruction_memory` — edit it (or regenerate it from assembly) to run a different program through the CPU.

## Design origins & disclosures

* **Textbook foundation.** The datapath and control scheme are based on the single-cycle MIPS processor in *Digital Design and Computer Architecture* by Sarah L. Harris and David Harris (Chapter 7, Section 7.3, p. 383). That base design covers `add`, `sub`, `and`, `or`, `slt`, `lw`, `sw`, `beq`, `addi`, and `j`. Starting from that architecture, I reimplemented it from scratch in SystemVerilog and extended it with instructions beyond the textbook's base subset: `xor`, `nor`, `sll`, `srl`, `sra`, `jr` (R-type), `andi`, `ori`, `lui` (I-type), `bne` (branch), and `jal` (jump-and-link).
* **ALU reuse.** The ALU (`ALU/src/`) is carried over from an earlier standalone ALU project of mine, with a handful of ports added (shift amount/shift value, additional flag outputs) to integrate it into this CPU.
* **AI assistance.** Claude was used heavily to help verify the design's correctness — writing/checking testbenches, tracing control logic, and debugging — but the substantial majority (~90%) of the actual RTL was written by hand.
