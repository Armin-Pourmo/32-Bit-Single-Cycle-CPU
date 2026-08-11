module CPU_tb;
localparam WIDTH = 32;

// A testbench is the simulation root — nothing instantiates it, so
// clk/reset can't be ports (nothing exists above us to drive them).
// They're plain variables that we drive ourselves below.
logic clk, reset;
logic [WIDTH-1:0] TEST_PC_OUT, TEST_INSTR, TEST_ALU_RESULT, TEST_RD_MEM;

CPU #(.WIDTH(WIDTH)) DUT (
    .clk(clk),
    .reset(reset),
    .TEST_PC_OUT(TEST_PC_OUT),
    .TEST_INSTR(TEST_INSTR),
    .TEST_ALU_RESULT(TEST_ALU_RESULT),
    .TEST_RD_MEM(TEST_RD_MEM)
);

// ── Clock ────────────────────────────────────────────────────────────────
always #5 clk = ~clk;

// ── Pass / fail counters ────────────────────────────────────────────────
int pass_count = 0;
int fail_count = 0;

// ── Self-check tasks ────────────────────────────────────────────────────
// These reach past the CPU's ports via hierarchical reference
// (DUT.REG_FILE.mem / DUT.DATA_MEMORY.mem) — simulation-only, but it's
// the only way to see committed architectural state, since real hardware
// doesn't expose a "read any register" debug port either.
// `expected` is never computed here — it's a literal YOU hand-traced
// from the ISA semantics of instructions.hex before running the sim.
task check_reg(input int idx, input logic [WIDTH-1:0] expected, input string label);
    if (DUT.REG_FILE.mem[idx] === expected) begin
        $display("PASS [%s] $%0d = %h", label, idx, DUT.REG_FILE.mem[idx]);
        pass_count++;
    end else begin
        $error("FAIL [%s] $%0d expected=%h got=%h", label, idx, expected, DUT.REG_FILE.mem[idx]);
        fail_count++;
    end
endtask

task check_mem(input int addr, input logic [WIDTH-1:0] expected, input string label);
    logic [WIDTH-1:0] actual;
    actual = {DUT.DATA_MEMORY.mem[addr+3], DUT.DATA_MEMORY.mem[addr+2],
              DUT.DATA_MEMORY.mem[addr+1], DUT.DATA_MEMORY.mem[addr]};
    if (actual === expected) begin
        $display("PASS [%s] mem[%0d] = %h", label, addr, actual);
        pass_count++;
    end else begin
        $error("FAIL [%s] mem[%0d] expected=%h got=%h", label, addr, expected, actual);
        fail_count++;
    end
endtask

// ── Stimulus ─────────────────────────────────────────────────────────────
// There's nothing to "wiggle" here — the CPU's behavior is entirely
// determined by instructions.hex (loaded into instruction_memory via
// $readmemh) once reset releases. The program itself IS the test vector.
initial begin
    $dumpfile("CPU/dump/cpu_tb.vcd");
    $dumpvars(0, CPU_tb);

    clk   = 0;
    reset = 1;
    #20 reset = 0;   // spans two clock edges — both resets in the design
                      // are synchronous (if(rst) inside always_ff), so
                      // reset must be held across at least one posedge.

    // instructions.hex is 7 single-cycle instructions; one commits per
    // clock edge, so 7 edges (70 time units) is enough — #200 is margin.
    #200;

    // ── Expected end state, hand-traced from instructions.hex ──────────
    // nor  $8,$0,$0        -> $8  = ~($0|$0)        = 0xFFFFFFFF
    // sw   $8,0($0)        -> mem[0]                = 0xFFFFFFFF
    // lw   $9,0($0)        -> $9  = mem[0]           = 0xFFFFFFFF
    // and  $10,$8,$9       -> $10 = $8 & $9           = 0xFFFFFFFF
    // beq  $8,$9,1         -> $8==$9, so branch IS taken, skipping the
    //                         next instruction
    // nor  $11,$0,$0       -> SKIPPED — $11 must stay at its reset value
    // or   $12,$8,$0       -> (branch target) $12 = $8 | $0 = 0xFFFFFFFF
    check_reg(8,  32'hFFFFFFFF, "nor $8,$0,$0");
    check_mem(0,  32'hFFFFFFFF, "sw $8,0($0)");
    check_reg(9,  32'hFFFFFFFF, "lw $9,0($0)");
    check_reg(10, 32'hFFFFFFFF, "and $10,$8,$9");
    check_reg(11, 32'h00000000, "nor $11 must be skipped by beq");
    check_reg(12, 32'hFFFFFFFF, "or $12,$8,$0 (branch landed here)");

    $display("──────────────────────────────────────────");
    $display("CPU testbench complete: %0d passed, %0d failed", pass_count, fail_count);
    if (fail_count == 0)
        $display("ALL TESTS PASSED");
    else
        $display("SOME TESTS FAILED — see errors above");
    $display("──────────────────────────────────────────");

    $finish;
end

// Live trace — handy for diagnosing a FAIL without opening the .vcd
initial begin
    $monitor("t=%0t PC=%h INSTR=%h ALU=%h RD_MEM=%h", $time, TEST_PC_OUT, TEST_INSTR, TEST_ALU_RESULT, TEST_RD_MEM);
end

endmodule
