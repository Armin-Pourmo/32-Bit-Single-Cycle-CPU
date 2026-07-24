module add_subtract_unit_tb;
localparam WIDTH = 32;

logic [WIDTH-1:0] a, b, sum, exp_sum, exp_diff;
logic             sub, cout, zero_flag, sign_flag, overflow;

add_subtract_unit #(.WIDTH(WIDTH)) dut (
    .a(a),
    .b(b),
    .sub(sub),
    .sum(sum),
    .cout(cout),
    .zero_flag(zero_flag),
    .sign_flag(sign_flag),
    .overflow_flag(overflow)
);

task check_add();
    exp_sum = a + b;
    if (exp_sum !== sum) begin
        $error("FAIL_ADD a=%h b=%h | exp=%h got=%h", a, b, exp_sum, sum);
    end else begin
        if (zero_flag !== (sum == '0))
            $error("FAIL zero_flag add a=%h b=%h | sum=%h zero_flag=%b", a, b, sum, zero_flag);
        if (sign_flag !== sum[WIDTH-1])
            $error("FAIL sign_flag add a=%h b=%h | sum=%h sign_flag=%b", a, b, sum, sign_flag);
        $display("PASS_ADD a=%h b=%h | sum=%h zero=%b sign=%b cout=%b overflow=%b",
                 a, b, sum, zero_flag, sign_flag, cout, overflow);
    end
endtask

task check_sub();
    exp_diff = a - b;
    if (exp_diff !== sum) begin
        $error("FAIL_SUB a=%h b=%h | exp=%h got=%h", a, b, exp_diff, sum);
    end else begin
        if (zero_flag !== (sum == '0))
            $error("FAIL zero_flag sub a=%h b=%h | sum=%h zero_flag=%b", a, b, sum, zero_flag);
        if (sign_flag !== sum[WIDTH-1])
            $error("FAIL sign_flag sub a=%h b=%h | sum=%h sign_flag=%b", a, b, sum, sign_flag);
        $display("PASS_SUB a=%h b=%h | sum=%h zero=%b sign=%b cout=%b overflow=%b",
                 a, b, sum, zero_flag, sign_flag, cout, overflow);
    end
endtask

task check_overflow(
    input logic [WIDTH-1:0] in_a, in_b,
    input logic             in_sub,
    input logic             exp_overflow,
    input string            label
);
    a = in_a; b = in_b; sub = in_sub; #10;
    if (overflow === exp_overflow)
        $display("PASS overflow [%s] a=%h b=%h | overflow=%b", label, a, b, overflow);
    else
        $error("FAIL overflow [%s] a=%h b=%h | expected=%b got=%b", label, a, b, exp_overflow, overflow);
endtask

initial begin
    $dumpfile("dump/add_subtract_unit_dump.vcd");
    $dumpvars(0, add_subtract_unit_tb);

    // ── Basic add/subtract correctness ───────────────────────────────
    sub = 0;
    a = 32'h00000000; b = 32'h00000000; #10; check_add();
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; #10; check_add();
    for (int i = 0; i < 50; i++) begin
        a = $urandom; b = $urandom; sub = 0; #10; check_add();
    end

    sub = 1;
    a = 32'h00000000; b = 32'h00000000; #10; check_sub();
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; #10; check_sub();
    for (int i = 0; i < 50; i++) begin
        a = $urandom; b = $urandom; sub = 1; #10; check_sub();
    end

    // ── Zero flag ────────────────────────────────────────────────────
    a = 32'h00000000; b = 32'h00000000; sub = 0; #10;
    if (zero_flag !== 1'b1) $error("FAIL zero_flag: 0+0 should set zero");
    else $display("PASS zero_flag set on 0+0");

    a = 32'hFFFFFFFF; b = 32'h00000001; sub = 0; #10;
    if (zero_flag !== 1'b1) $error("FAIL zero_flag: 0xFFFFFFFF+1 should set zero (wraps)");
    else $display("PASS zero_flag set on wraparound");

    a = 32'h00000001; b = 32'h00000000; sub = 0; #10;
    if (zero_flag !== 1'b0) $error("FAIL zero_flag: should be clear for non-zero result");
    else $display("PASS zero_flag clear on non-zero");

    // ── Sign flag ────────────────────────────────────────────────────
    a = 32'h40000000; b = 32'h40000000; sub = 0; #10;
    if (sign_flag !== 1'b1) $error("FAIL sign_flag: 0x40+0x40=0x80, MSB should be 1");
    else $display("PASS sign_flag set when MSB=1");

    a = 32'h00000001; b = 32'h00000001; sub = 0; #10;
    if (sign_flag !== 1'b0) $error("FAIL sign_flag: should be clear for positive result");
    else $display("PASS sign_flag clear when MSB=0");

    // ── Overflow flag ────────────────────────────────────────────────
    // pos + pos = neg (overflow)
    check_overflow(32'h7FFFFFFF, 32'h00000001, 0, 1, "pos+pos=neg");
    // neg + neg = pos (overflow)
    check_overflow(32'h80000000, 32'h80000000, 0, 1, "neg+neg=pos");
    // pos + neg = no overflow
    check_overflow(32'h7FFFFFFF, 32'h80000000, 0, 0, "pos+neg no overflow");
    // normal add no overflow
    check_overflow(32'h00000001, 32'h00000001, 0, 0, "1+1 no overflow");
    // sub: most negative - 1 (overflow)
    check_overflow(32'h80000000, 32'h00000001, 1, 1, "most_neg-1 overflow");
    // sub: -1 - 1 = no overflow
    check_overflow(32'hFFFFFFFF, 32'h00000001, 1, 0, "-1-1 no overflow");

    $display("All add_subtract_unit tests complete");
    $finish;
end
endmodule
