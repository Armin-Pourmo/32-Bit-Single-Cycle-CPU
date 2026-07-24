module alu_tb;
localparam WIDTH = 32;

// ── Signals ──────────────────────────────────────────────────────────────────
logic [WIDTH-1:0] a, b, result;
logic [3:0]       opcode;
logic             zero, sign, overflow, carry;

// ── DUT instantiation ────────────────────────────────────────────────────────
alu #(.WIDTH(WIDTH)) dut (
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(result),
    .zero(zero),
    .sign(sign),
    .overflow(overflow),
    .carry(carry)
);

// ── Opcode map (mirrors decoder.sv) ─────────────────────────────────────────
localparam OP_AND = 4'b0000;
localparam OP_OR  = 4'b0001;
localparam OP_XOR = 4'b0010;
localparam OP_NOR = 4'b0011;
localparam OP_ADD = 4'b0100;
localparam OP_SUB = 4'b0101;
localparam OP_LSL = 4'b0110;
localparam OP_LSR = 4'b0111;
localparam OP_ASR = 4'b1000;

// ── Pass / fail counters ─────────────────────────────────────────────────────
int pass_count = 0;
int fail_count = 0;

// ── Generic check task ───────────────────────────────────────────────────────
// Call this after setting a, b, opcode and waiting #10.
// It compares result against expected and prints PASS / FAIL.
task check_result(
    input logic [WIDTH-1:0] expected,
    input string            label
);
    if (result === expected) begin
        $display("PASS [%s] op=%04b a=%h b=%h | result=%h", label, opcode, a, b, result);
        pass_count++;
    end else begin
        $error("FAIL [%s] op=%04b a=%h b=%h | expected=%h got=%h", label, opcode, a, b, expected, result);
        fail_count++;
    end
endtask

// ── Flag check task ──────────────────────────────────────────────────────────
// Only used for arithmetic ops where flags matter.
// Pass 1'bx for any flag you don't want to check.
task check_flags(
    input logic exp_zero, exp_sign, exp_overflow, exp_carry,
    input string label
);
    if (exp_zero !== 1'bx && zero !== exp_zero) begin
        $error("FAIL [%s] zero flag | expected=%b got=%b", label, exp_zero, zero);
        fail_count++;
    end
    if (exp_sign !== 1'bx && sign !== exp_sign) begin
        $error("FAIL [%s] sign flag | expected=%b got=%b", label, exp_sign, sign);
        fail_count++;
    end
    if (exp_overflow !== 1'bx && overflow !== exp_overflow) begin
        $error("FAIL [%s] overflow flag | expected=%b got=%b", label, exp_overflow, overflow);
        fail_count++;
    end
    if (exp_carry !== 1'bx && carry !== exp_carry) begin
        $error("FAIL [%s] carry flag | expected=%b got=%b", label, exp_carry, carry);
        fail_count++;
    end
endtask

// ─────────────────────────────────────────────────────────────────────────────
initial begin
    $dumpfile("dump/alu.vcd");
    $dumpvars(0, alu_tb);

    // =========================================================================
    // 1. ADD (opcode 0100)
    // =========================================================================
    // Why test ADD first: it is the most fundamental op and flags only come
    // from the add_subtract_unit, so verifying them here covers the flag path
    // for the whole ALU at once.
    opcode = OP_ADD;

    // 0 + 0 → zero flag set, carry clear, no overflow
    a = 32'h00000000; b = 32'h00000000; #10;
    check_result(32'h00000000, "ADD 0+0");
    check_flags(1, 0, 0, 0, "ADD 0+0 flags");

    // Simple sum
    a = 32'h00000001; b = 32'h00000001; #10;
    check_result(32'h00000002, "ADD 1+1");
    check_flags(0, 0, 0, 0, "ADD 1+1 flags");

    // Result has MSB set → sign flag
    a = 32'h40000000; b = 32'h40000000; #10;
    check_result(32'h80000000, "ADD sign flag");
    check_flags(0, 1, 1, 0, "ADD sign+overflow flags");

    // Unsigned wraparound → carry out, zero result
    a = 32'hFFFFFFFF; b = 32'h00000001; #10;
    check_result(32'h00000000, "ADD wraparound");
    check_flags(1, 0, 0, 1, "ADD wraparound flags");

    // Max unsigned + max unsigned
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; #10;
    check_result(32'hFFFFFFFE, "ADD max+max");
    check_flags(0, 1, 0, 1, "ADD max+max flags");

    // Positive overflow: largest positive + 1 wraps to most-negative
    a = 32'h7FFFFFFF; b = 32'h00000001; #10;
    check_result(32'h80000000, "ADD pos overflow");
    check_flags(0, 1, 1, 0, "ADD pos overflow flags");

    // Negative overflow: most-negative + most-negative wraps to zero (signed)
    a = 32'h80000000; b = 32'h80000000; #10;
    check_result(32'h00000000, "ADD neg overflow");
    check_flags(1, 0, 1, 1, "ADD neg overflow flags");

    // Random directed values
    for (int i = 0; i < 30; i++) begin
        a = $urandom; b = $urandom; #10;
        check_result(a + b, "ADD random");
    end

    // =========================================================================
    // 2. SUB (opcode 0101)
    // =========================================================================
    // Subtraction reuses the adder with b inverted + carry-in 1 (two's complement).
    // We check that the ALU result equals a - b and that flags are correct.
    opcode = OP_SUB;

    // 0 - 0 = 0, zero flag
    a = 32'h00000000; b = 32'h00000000; #10;
    check_result(32'h00000000, "SUB 0-0");
    check_flags(1, 0, 0, 1, "SUB 0-0 flags");
    // Note: carry=1 here because subtraction via two's complement of 0 produces
    // a carry-out of 1 (borrow-out is inverted carry).

    // Simple subtraction
    a = 32'h00000005; b = 32'h00000003; #10;
    check_result(32'h00000002, "SUB 5-3");
    check_flags(0, 0, 0, 1, "SUB 5-3 flags");

    // a < b → borrow (negative result, sign flag, carry=0)
    a = 32'h00000001; b = 32'h00000002; #10;
    check_result(32'hFFFFFFFF, "SUB underflow");
    check_flags(0, 1, 0, 0, "SUB underflow flags");

    // Signed overflow: most-negative - 1 wraps to most-positive
    // carry=1 because a + (~b) + 1 = 0x80000000 + 0xFFFFFFFE + 1 produces a carry-out
    a = 32'h80000000; b = 32'h00000001; #10;
    check_result(32'h7FFFFFFF, "SUB neg overflow");
    check_flags(0, 0, 1, 1, "SUB neg overflow flags");

    // a = b → zero
    a = 32'hDEADBEEF; b = 32'hDEADBEEF; #10;
    check_result(32'h00000000, "SUB equal");
    check_flags(1, 0, 0, 1, "SUB equal flags");

    for (int i = 0; i < 30; i++) begin
        a = $urandom; b = $urandom; #10;
        check_result(a - b, "SUB random");
    end

    // =========================================================================
    // 3. AND (opcode 0000)
    // =========================================================================
    opcode = OP_AND;

    a = 32'h00000000; b = 32'h00000000; #10; check_result(32'h00000000, "AND 0&0");
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; #10; check_result(32'hFFFFFFFF, "AND F&F");
    a = 32'hFFFFFFFF; b = 32'h00000000; #10; check_result(32'h00000000, "AND F&0");
    // Alternating bit patterns cancel each other
    a = 32'hAAAAAAAA; b = 32'h55555555; #10; check_result(32'h00000000, "AND alternating");
    // Masking lower byte
    a = 32'hDEADBEEF; b = 32'h000000FF; #10; check_result(32'h000000EF, "AND mask low byte");

    for (int i = 0; i < 20; i++) begin
        a = $urandom; b = $urandom; #10;
        check_result(a & b, "AND random");
    end

    // =========================================================================
    // 4. OR (opcode 0001)
    // =========================================================================
    opcode = OP_OR;

    a = 32'h00000000; b = 32'h00000000; #10; check_result(32'h00000000, "OR 0|0");
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; #10; check_result(32'hFFFFFFFF, "OR F|F");
    a = 32'h00000000; b = 32'hDEADBEEF; #10; check_result(32'hDEADBEEF, "OR with zero identity");
    a = 32'hAAAAAAAA; b = 32'h55555555; #10; check_result(32'hFFFFFFFF, "OR alternating");

    for (int i = 0; i < 20; i++) begin
        a = $urandom; b = $urandom; #10;
        check_result(a | b, "OR random");
    end

    // =========================================================================
    // 5. XOR (opcode 0010)
    // =========================================================================
    opcode = OP_XOR;

    a = 32'h00000000; b = 32'h00000000; #10; check_result(32'h00000000, "XOR 0^0");
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; #10; check_result(32'h00000000, "XOR same=0");
    a = 32'hFFFFFFFF; b = 32'h00000000; #10; check_result(32'hFFFFFFFF, "XOR F^0 identity");
    a = 32'hAAAAAAAA; b = 32'h55555555; #10; check_result(32'hFFFFFFFF, "XOR alternating");
    // XOR is its own inverse: a^b^b = a
    a = 32'hDEADBEEF; b = 32'hCAFEBABE; #10;
    check_result(32'hDEADBEEF ^ 32'hCAFEBABE, "XOR known values");

    for (int i = 0; i < 20; i++) begin
        a = $urandom; b = $urandom; #10;
        check_result(a ^ b, "XOR random");
    end

    // =========================================================================
    // 6. NOR (opcode 0011)
    // =========================================================================
    opcode = OP_NOR;

    a = 32'h00000000; b = 32'h00000000; #10; check_result(32'hFFFFFFFF, "NOR 0|0 inverted");
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; #10; check_result(32'h00000000, "NOR all ones");
    a = 32'hAAAAAAAA; b = 32'h55555555; #10; check_result(32'h00000000, "NOR alternating");
    a = 32'h00000000; b = 32'h0F0F0F0F; #10; check_result(32'hF0F0F0F0, "NOR partial");

    for (int i = 0; i < 20; i++) begin
        a = $urandom; b = $urandom; #10;
        check_result(~(a | b), "NOR random");
    end

    // =========================================================================
    // 7. LSL – Logical Shift Left (opcode 0110)
    // =========================================================================
    // b[4:0] is the shift amount (shamt). b upper bits are ignored by the ALU.
    opcode = OP_LSL;

    a = 32'h00000001; b = 32'd0;  #10; check_result(32'h00000001, "LSL by 0 (no-op)");
    a = 32'h00000001; b = 32'd1;  #10; check_result(32'h00000002, "LSL by 1");
    a = 32'h00000001; b = 32'd4;  #10; check_result(32'h00000010, "LSL by 4");
    a = 32'h00000001; b = 32'd31; #10; check_result(32'h80000000, "LSL by 31");
    // Shifting out all bits
    a = 32'hFFFFFFFF; b = 32'd31; #10; check_result(32'h80000000, "LSL all-ones by 31");
    // MSBs are dropped, zeros fill from right
    a = 32'hFFFFFFFF; b = 32'd4;  #10; check_result(32'hFFFFFFF0, "LSL drops MSBs");

    // =========================================================================
    // 8. LSR – Logical Shift Right (opcode 0111)
    // =========================================================================
    // Zeros fill from the left regardless of the sign bit.
    opcode = OP_LSR;

    a = 32'h80000000; b = 32'd1;  #10; check_result(32'h40000000, "LSR MSB fills 0");
    a = 32'h80000000; b = 32'd31; #10; check_result(32'h00000001, "LSR by 31");
    a = 32'hFFFFFFFF; b = 32'd4;  #10; check_result(32'h0FFFFFFF, "LSR by 4");
    a = 32'h00000001; b = 32'd1;  #10; check_result(32'h00000000, "LSR drops LSB");
    a = 32'h00000001; b = 32'd0;  #10; check_result(32'h00000001, "LSR by 0 (no-op)");

    // =========================================================================
    // 9. ASR – Arithmetic Shift Right (opcode 1000)
    // =========================================================================
    // The sign bit is replicated as bits shift in from the left.
    // Positive inputs (MSB=0) behave identically to LSR.
    opcode = OP_ASR;

    // Negative input → fills 1s
    a = 32'h80000000; b = 32'd1;  #10; check_result(32'hC0000000, "ASR neg by 1");
    a = 32'h80000000; b = 32'd4;  #10; check_result(32'hF8000000, "ASR neg by 4");
    a = 32'h80000000; b = 32'd31; #10; check_result(32'hFFFFFFFF, "ASR neg by 31");
    a = 32'hFFFF0000; b = 32'd8;  #10; check_result(32'hFFFFFF00, "ASR neg fills 1s");

    // Positive input → fills 0s (same as LSR)
    a = 32'h40000000; b = 32'd1;  #10; check_result(32'h20000000, "ASR pos by 1");
    a = 32'h7FFFFFFF; b = 32'd4;  #10; check_result(32'h07FFFFFF, "ASR pos by 4");

    // Shift by 0 is a no-op for both signed and unsigned
    a = 32'hDEADBEEF; b = 32'd0;  #10; check_result(32'hDEADBEEF, "ASR by 0 (no-op)");

    // =========================================================================
    // 10. Default / undefined opcodes
    // =========================================================================
    // The decoder's default case sets operation=2'b00 (add path) and all
    // control signals to 0 (add with sub=0). We just verify no X/Z on result.
    opcode = 4'b1001; a = 32'h0; b = 32'h0; #10;
    if (^result === 1'bx)
        $error("FAIL [undefined opcode 1001] result contains X/Z");
    else
        $display("PASS [undefined opcode 1001] result is defined: %h", result);

    opcode = 4'b1111; a = 32'h0; b = 32'h0; #10;
    if (^result === 1'bx)
        $error("FAIL [undefined opcode 1111] result contains X/Z");
    else
        $display("PASS [undefined opcode 1111] result is defined: %h", result);

    // =========================================================================
    // Summary
    // =========================================================================
    $display("──────────────────────────────────────────");
    $display("ALU testbench complete: %0d passed, %0d failed", pass_count, fail_count);
    if (fail_count == 0)
        $display("ALL TESTS PASSED");
    else
        $display("SOME TESTS FAILED — see errors above");
    $display("──────────────────────────────────────────");

    $finish;
end

endmodule
