module shift_unit_tb;
localparam WIDTH = 32;

logic [WIDTH-1:0] data, result;
logic [4:0]       shamt;
logic             direction, arithmetic;

shift_unit #(.WIDTH(WIDTH)) dut (
    .data(data),
    .shamt(shamt),
    .direction(direction),
    .arithmetic(arithmetic),
    .result(result)
);

task check(
    input logic [WIDTH-1:0] expected,
    input string            label
);
    if (result === expected)
        $display("PASS [%s] data=%h shamt=%0d dir=%b arith=%b | result=%h",
                 label, data, shamt, direction, arithmetic, result);
    else
        $error("FAIL [%s] data=%h shamt=%0d dir=%b arith=%b | expected=%h got=%h",
               label, data, shamt, direction, arithmetic, expected, result);
endtask

initial begin
    $dumpfile("dump/shift_unit.vcd");
    $dumpvars(0, shift_unit_tb);

    // ── LSL (direction=0, arithmetic=0) ──────────────────────────────
    direction = 0; arithmetic = 0;

    data = 32'h00000001; shamt = 0;  #5; check(32'h00000001, "LSL by 0");
    data = 32'h00000001; shamt = 1;  #5; check(32'h00000002, "LSL by 1");
    data = 32'h00000001; shamt = 4;  #5; check(32'h00000010, "LSL by 4");
    data = 32'h00000001; shamt = 31; #5; check(32'h80000000, "LSL by 31");
    data = 32'hFFFFFFFF; shamt = 4;  #5; check(32'hFFFFFFF0, "LSL drops MSBs");
    data = 32'hFFFFFFFF; shamt = 31; #5; check(32'h80000000, "LSL by 31 all ones");

    // ── LSR (direction=1, arithmetic=0) ──────────────────────────────
    direction = 1; arithmetic = 0;

    data = 32'h80000000; shamt = 1;  #5; check(32'h40000000, "LSR fills 0 not sign");
    data = 32'h80000000; shamt = 31; #5; check(32'h00000001, "LSR by 31");
    data = 32'hFFFFFFFF; shamt = 4;  #5; check(32'h0FFFFFFF, "LSR by 4");
    data = 32'h00000001; shamt = 1;  #5; check(32'h00000000, "LSR drops LSB");

    // ── ASR (direction=1, arithmetic=1) ──────────────────────────────
    direction = 1; arithmetic = 1;

    // Negative number (MSB=1): should fill 1s
    data = 32'h80000000; shamt = 1;  #5; check(32'hC0000000, "ASR negative by 1");
    data = 32'h80000000; shamt = 4;  #5; check(32'hF8000000, "ASR negative by 4");
    data = 32'hFFFF0000; shamt = 8;  #5; check(32'hFFFFFF00, "ASR negative fills 1s");
    data = 32'h80000000; shamt = 31; #5; check(32'hFFFFFFFF, "ASR negative by 31");

    // Positive number (MSB=0): should fill 0s (same as LSR)
    data = 32'h40000000; shamt = 1;  #5; check(32'h20000000, "ASR positive by 1");
    data = 32'h7FFFFFFF; shamt = 4;  #5; check(32'h07FFFFFF, "ASR positive by 4");

    $display("shift_unit tests complete");
    $finish;
end
endmodule
