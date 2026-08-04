module decoder_unit_tb;
localparam WIDTH = 32;

// ── Signals ──────────────────────────────────────────────────────────────────
logic [WIDTH-1:0] INSTRUCTION;
logic [4:0]  RS, RT, RD;
logic [4:0]  SHIFT_AMNT;
logic [5:0]  FUNC;
logic [15:0] IMMEDIATE;
logic [5:0]  OPCODE;
logic [25:0] ADDR;

// ── DUT instantiation ────────────────────────────────────────────────────────
decoder_unit #(.WIDTH(WIDTH)) dut (
    .INSTRUCTION(INSTRUCTION),
    .RS(RS), .RT(RT), .RD(RD),
    .SHIFT_AMNT(SHIFT_AMNT),
    .FUNC(FUNC),
    .IMMEDIATE(IMMEDIATE),
    .OPCODE(OPCODE),
    .ADDR(ADDR)
);

int pass_count = 0;
int fail_count = 0;

// ── Field builder helpers ────────────────────────────────────────────────────
function automatic logic [31:0] make_r(
    input logic [5:0] opcode, input logic [4:0] rs, rt, rd, shamt, input logic [5:0] funct
);
    return {opcode, rs, rt, rd, shamt, funct};
endfunction

function automatic logic [31:0] make_i(
    input logic [5:0] opcode, input logic [4:0] rs, rt, input logic [15:0] imm
);
    return {opcode, rs, rt, imm};
endfunction

function automatic logic [31:0] make_j(
    input logic [5:0] opcode, input logic [25:0] addr
);
    return {opcode, addr};
endfunction

// ── Check task ────────────────────────────────────────────────────────────────
task check(
    input logic [4:0]  exp_rs, exp_rt, exp_rd, exp_shamt,
    input logic [5:0]  exp_func,
    input logic [15:0] exp_imm,
    input logic [5:0]  exp_opcode,
    input logic [25:0] exp_addr,
    input string        label
);
    #10;
    fail_count += (OPCODE     !== exp_opcode);
    fail_count += (RS         !== exp_rs);
    fail_count += (RT         !== exp_rt);
    fail_count += (RD         !== exp_rd);
    fail_count += (SHIFT_AMNT !== exp_shamt);
    fail_count += (FUNC       !== exp_func);
    fail_count += (IMMEDIATE  !== exp_imm);
    fail_count += (ADDR       !== exp_addr);

    if (OPCODE === exp_opcode && RS === exp_rs && RT === exp_rt && RD === exp_rd &&
        SHIFT_AMNT === exp_shamt && FUNC === exp_func &&
        IMMEDIATE === exp_imm && ADDR === exp_addr) begin
        $display("PASS [%s] opcode=%06b rs=%0d rt=%0d rd=%0d shamt=%0d func=%06b imm=%h addr=%h",
                  label, OPCODE, RS, RT, RD, SHIFT_AMNT, FUNC, IMMEDIATE, ADDR);
        pass_count++;
    end else begin
        $error("FAIL [%s] opcode=%06b(exp %06b) rs=%0d(exp %0d) rt=%0d(exp %0d) rd=%0d(exp %0d) shamt=%0d(exp %0d) func=%06b(exp %06b) imm=%h(exp %h) addr=%h(exp %h)",
                  label, OPCODE, exp_opcode, RS, exp_rs, RT, exp_rt, RD, exp_rd,
                  SHIFT_AMNT, exp_shamt, FUNC, exp_func, IMMEDIATE, exp_imm, ADDR, exp_addr);
    end
endtask

initial begin
    //$dumpfile("Instruction_Unit/dump/decoder_unit.vcd");
    //$dumpvars(0, decoder_unit_tb);

    // =========================================================================
    // 1. R-type (opcode 000000)
    // =========================================================================
    // add $8, $9, $10  -> rs=9, rt=10, rd=8, shamt=0, funct=0x20
    INSTRUCTION = make_r(6'b000000, 5'd9, 5'd10, 5'd8, 5'd0, 6'h20);
    check(5'd9, 5'd10, 5'd8, 5'd0, 6'h20, 16'h0, 6'b000000, 26'h0, "R-type add");

    // sll $1, $2, 4 -> rs=0, rt=2, rd=1, shamt=4, funct=0x00
    INSTRUCTION = make_r(6'b000000, 5'd0, 5'd2, 5'd1, 5'd4, 6'h00);
    check(5'd0, 5'd2, 5'd1, 5'd4, 6'h00, 16'h0, 6'b000000, 26'h0, "R-type sll");

    // random R-type fields
    INSTRUCTION = make_r(6'b000000, 5'd17, 5'd23, 5'd31, 5'd15, 6'h22); // sub
    check(5'd17, 5'd23, 5'd31, 5'd15, 6'h22, 16'h0, 6'b000000, 26'h0, "R-type sub random regs");

    // =========================================================================
    // 2. I-type (any opcode other than 000000 / 000010 / 000011)
    // =========================================================================
    // lw $8, 100($9) -> opcode=0x23, rs=9, rt=8, imm=100
    INSTRUCTION = make_i(6'h23, 5'd9, 5'd8, 16'd100);
    check(5'd9, 5'd8, 5'd0, 5'd0, 6'h0, 16'd100, 6'h23, 26'h0, "I-type lw");

    // sw $10, -4($sp=29) -> opcode=0x2B, rs=29, rt=10, imm=0xFFFC
    INSTRUCTION = make_i(6'h2B, 5'd29, 5'd10, 16'hFFFC);
    check(5'd29, 5'd10, 5'd0, 5'd0, 6'h0, 16'hFFFC, 6'h2B, 26'h0, "I-type sw negative imm");

    // addi $1, $2, 42 -> opcode=0x08
    INSTRUCTION = make_i(6'h08, 5'd2, 5'd1, 16'd42);
    check(5'd2, 5'd1, 5'd0, 5'd0, 6'h0, 16'd42, 6'h08, 26'h0, "I-type addi");

    // beq $3, $4, offset -> opcode=0x04
    INSTRUCTION = make_i(6'h04, 5'd3, 5'd4, 16'hABCD);
    check(5'd3, 5'd4, 5'd0, 5'd0, 6'h0, 16'hABCD, 6'h04, 26'h0, "I-type beq");

    // =========================================================================
    // 3. J-type (opcode 000010 = j, 000011 = jal)
    // =========================================================================
    INSTRUCTION = make_j(6'b000010, 26'h0000064);
    check(5'd0, 5'd0, 5'd0, 5'd0, 6'h0, 16'h0, 6'b000010, 26'h0000064, "J-type j");

    INSTRUCTION = make_j(6'b000011, 26'h3FFFFFF);
    check(5'd0, 5'd0, 5'd0, 5'd0, 6'h0, 16'h0, 6'b000011, 26'h3FFFFFF, "J-type jal max addr");

    // =========================================================================
    // Summary
    // =========================================================================
    $display("──────────────────────────────────────────");
    $display("decoder_unit testbench complete: %0d passed, %0d failed", pass_count, fail_count);
    if (fail_count == 0)
        $display("ALL TESTS PASSED");
    else
        $display("SOME TESTS FAILED — see errors above");
    $display("──────────────────────────────────────────");

    $finish;
end

endmodule
