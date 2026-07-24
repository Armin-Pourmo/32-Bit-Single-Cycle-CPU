module logic_unit_tb;
localparam WIDTH = 32;

logic [WIDTH-1:0] a, b, result;
logic [3:0]       opcode;

logic_unit #(.WIDTH(WIDTH)) dut (
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(result)
);

task check(
    input logic [WIDTH-1:0] expected,
    input string            label
);
    #5;
    if (result === expected)
        $display("PASS [%s] a=%h b=%h op=%04b | result=%h", label, a, b, opcode, result);
    else
        $error("FAIL [%s] a=%h b=%h op=%04b | expected=%h got=%h", label, a, b, opcode, expected, result);
endtask

initial begin
    $dumpfile("dump/logic_unit.vcd");
    $dumpvars(0, logic_unit_tb);

    // ── AND (opcode[1:0] = 2'b00) ────────────────────────────────────
    opcode = 4'b0000;
    a = 32'h00000000; b = 32'h00000000; check(32'h00000000, "AND all zeros");
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; check(32'hFFFFFFFF, "AND all ones");
    a = 32'hAAAAAAAA; b = 32'h55555555; check(32'h00000000, "AND alternating");
    a = 32'hFFFFFFFF; b = 32'h0F0F0F0F; check(32'h0F0F0F0F, "AND mask");
    for (int i = 0; i < 20; i++) begin
        a = $urandom; b = $urandom;
        check(a & b, "AND random");
    end

    // ── OR (opcode[1:0] = 2'b01) ─────────────────────────────────────
    opcode = 4'b0001;
    a = 32'h00000000; b = 32'h00000000; check(32'h00000000, "OR all zeros");
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; check(32'hFFFFFFFF, "OR all ones");
    a = 32'hAAAAAAAA; b = 32'h55555555; check(32'hFFFFFFFF, "OR alternating");
    a = 32'h00000000; b = 32'h0F0F0F0F; check(32'h0F0F0F0F, "OR with zero");
    for (int i = 0; i < 20; i++) begin
        a = $urandom; b = $urandom;
        check(a | b, "OR random");
    end

    // ── XOR (opcode[1:0] = 2'b10) ────────────────────────────────────
    opcode = 4'b0010;
    a = 32'h00000000; b = 32'h00000000; check(32'h00000000, "XOR all zeros");
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; check(32'h00000000, "XOR same clears");
    a = 32'hAAAAAAAA; b = 32'h55555555; check(32'hFFFFFFFF, "XOR alternating");
    a = 32'hFFFFFFFF; b = 32'h00000000; check(32'hFFFFFFFF, "XOR with zero");
    for (int i = 0; i < 20; i++) begin
        a = $urandom; b = $urandom;
        check(a ^ b, "XOR random");
    end

    // ── NOR (opcode[1:0] = 2'b11) ────────────────────────────────────
    opcode = 4'b0011;
    a = 32'h00000000; b = 32'h00000000; check(32'hFFFFFFFF, "NOR all zeros");
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; check(32'h00000000, "NOR all ones");
    a = 32'hAAAAAAAA; b = 32'h55555555; check(32'h00000000, "NOR alternating");
    a = 32'h00000000; b = 32'h0F0F0F0F; check(32'hF0F0F0F0, "NOR partial");
    for (int i = 0; i < 20; i++) begin
        a = $urandom; b = $urandom;
        check(~(a | b), "NOR random");
    end

    $display("All logic_unit tests complete");
    $finish;
end
endmodule
