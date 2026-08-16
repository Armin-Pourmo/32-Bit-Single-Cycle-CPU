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

    // instructions.hex is 29 single-cycle instructions; one commits per
    // clock edge, so 29 edges (290 time units) is enough — #350 is margin.
    #350;

    // ── Expected end state, hand-traced from instructions.hex ──────────
    // Covers every instruction the ISA currently implements, each at least
    // once: NOR/AND/OR/ADD/SUB/XOR/SLT/SLL/SRL/SRA/JR (R-type), LW/SW/ADDI/
    // ANDI/ORI/BEQ/BNE/LUI (I-type), J/JAL (J-type).
    //
    // nor  $8,$0,$0        -> $8  = ~($0|$0)        = 0xFFFFFFFF
    // sw   $8,0($0)        -> mem[0]                = 0xFFFFFFFF
    // lw   $9,0($0)        -> $9  = mem[0]           = 0xFFFFFFFF
    // and  $10,$8,$9       -> $10 = $8 & $9           = 0xFFFFFFFF
    // beq  $8,$9,1         -> $8==$9, so branch IS taken, skipping the
    //                         next instruction
    // nor  $11,$0,$0       -> SKIPPED — $11 must stay at its reset value
    // or   $12,$8,$0       -> (branch target) $12 = $8 | $0 = 0xFFFFFFFF
    // addi $13,$0,5        -> $13 = 0+5              = 5
    // add  $14,$13,$13     -> $14 = 5+5               = 10
    // sub  $15,$14,$13     -> $15 = 10-5              = 5
    // slt  $16,$13,$14     -> $13(5) < $14(10)        -> $16 = 1
    // xor  $17,$13,$14     -> 5 ^ 10                  = 15 (0xF)
    // sll  $18,$13,2       -> 5 << 2                  = 20 (0x14)
    // srl  $19,$18,2       -> 20 >> 2                 = 5
    // sra  $20,$8,4        -> 0xFFFFFFFF >>> 4        = 0xFFFFFFFF (arithmetic: sign-fills)
    // andi $21,$13,3       -> 5 & 3 (zero-ext imm)    = 1
    // ori  $22,$13,8       -> 5 | 8 (zero-ext imm)    = 13 (0xD)
    // bne  $13,$14,1       -> 5!=10, so branch IS taken, skipping the
    //                         next instruction
    // nor  $23,$0,$0       -> SKIPPED — $23 must stay at its reset value
    // addi $24,$0,7        -> (branch target) $24 = 0+7 = 7
    // j    0x58            -> unconditional jump, skipping the next
    //                         instruction
    // nor  $25,$0,$0       -> SKIPPED — $25 must stay at its reset value
    // addi $26,$0,9        -> (jump target) $26 = 0+9 = 9
    // lui  $27,0x1234      -> $27 = 0x1234 << 16 = 0x12340000
    // j    0x6C             -> unconditionally skip the function body below;
    //                          it must only ever be entered via jal
    // (function body, reached only via jal below)
    //   addi $29,$0,0x99   -> [FUNC] proves jal actually jumped here
    //   jr   $31           -> return using the address jal saved in $31
    // jal  0x64             -> $31 = PC+4 = 0x70 (return address); jump to
    //                          the function above
    // addi $28,$0,0x42      -> AFTER-CALL: only reached if jr correctly
    //                          returned using $31 — proves the full
    //                          call/return round trip works
    check_reg(8,  32'hFFFFFFFF, "nor $8,$0,$0");
    check_mem(0,  32'hFFFFFFFF, "sw $8,0($0)");
    check_reg(9,  32'hFFFFFFFF, "lw $9,0($0)");
    check_reg(10, 32'hFFFFFFFF, "and $10,$8,$9");
    check_reg(11, 32'h00000000, "nor $11 must be skipped by beq");
    check_reg(12, 32'hFFFFFFFF, "or $12,$8,$0 (branch landed here)");
    check_reg(13, 32'd5,        "addi $13,$0,5");
    check_reg(14, 32'd10,       "add $14,$13,$13");
    check_reg(15, 32'd5,        "sub $15,$14,$13");
    check_reg(16, 32'd1,        "slt $16,$13,$14");
    check_reg(17, 32'd15,       "xor $17,$13,$14");
    check_reg(18, 32'd20,       "sll $18,$13,2");
    check_reg(19, 32'd5,        "srl $19,$18,2");
    check_reg(20, 32'hFFFFFFFF, "sra $20,$8,4");
    check_reg(21, 32'd1,        "andi $21,$13,3");
    check_reg(22, 32'd13,       "ori $22,$13,8");
    check_reg(23, 32'h00000000, "nor $23 must be skipped by bne");
    check_reg(24, 32'd7,        "addi $24,$0,7 (bne landed here)");
    check_reg(25, 32'h00000000, "nor $25 must be skipped by j");
    check_reg(26, 32'd9,        "addi $26,$0,9 (j landed here)");
    check_reg(27, 32'h12340000, "lui $27,0x1234");
    check_reg(31, 32'h00000070, "jal $31 = return address (link write)");
    check_reg(29, 32'h00000099, "addi $29 inside jal's target -- proves jal jumped");
    check_reg(28, 32'h00000042, "addi $28 after jr returns -- proves call/return round trip works");

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
