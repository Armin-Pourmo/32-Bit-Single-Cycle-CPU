module bit_extender_tb;
localparam WIDTH     = 32;
localparam IMM_WIDTH = 16;

logic                    EXT_Op;
logic [IMM_WIDTH-1:0]    immediate_var;
logic [WIDTH-1:0]        extended_var;

bit_extender #(.WIDTH(WIDTH), .IMM_WIDTH(IMM_WIDTH)) dut (
    .EXT_Op(EXT_Op),
    .immediate_var(immediate_var),
    .extended_var(extended_var)
);

int pass_count = 0;
int fail_count = 0;

task check(
    input logic [WIDTH-1:0] expected,
    input string            label
);
    #5;
    if (extended_var === expected) begin
        $display("PASS [%s] EXT_Op=%b imm=%h | extended=%h", label, EXT_Op, immediate_var, extended_var);
        pass_count++;
    end else begin
        $error("FAIL [%s] EXT_Op=%b imm=%h | expected=%h got=%h", label, EXT_Op, immediate_var, expected, extended_var);
        fail_count++;
    end
endtask

initial begin
    $dumpfile("dump/bit_extender.vcd");
    $dumpvars(0, bit_extender_tb);

    // ── Sign extend (EXT_Op = 0) — addi/lw/sw/beq/bne ───────────────────
    EXT_Op = 1'b0;
    immediate_var = 16'h0000; check(32'h00000000, "sign-extend zero");
    immediate_var = 16'hFFFF; check(32'hFFFFFFFF, "sign-extend all ones");
    immediate_var = 16'h8000; check(32'hFFFF8000, "sign-extend negative MSB set");
    immediate_var = 16'h7FFF; check(32'h00007FFF, "sign-extend max positive");
    immediate_var = 16'h0001; check(32'h00000001, "sign-extend positive one");
    immediate_var = 16'hABCD; check(32'hFFFFABCD, "sign-extend negative pattern");
    for (int i = 0; i < 20; i++) begin
        immediate_var = $urandom;
        check({{16{immediate_var[15]}}, immediate_var}, "sign-extend random");
    end

    // ── Zero extend (EXT_Op = 1) — andi/ori ─────────────────────────────
    EXT_Op = 1'b1;
    immediate_var = 16'h0000; check(32'h00000000, "zero-extend zero");
    immediate_var = 16'hFFFF; check(32'h0000FFFF, "zero-extend all ones");
    immediate_var = 16'h8000; check(32'h00008000, "zero-extend MSB set");
    immediate_var = 16'hABCD; check(32'h0000ABCD, "zero-extend pattern");
    for (int i = 0; i < 20; i++) begin
        immediate_var = $urandom;
        check({16'h0000, immediate_var}, "zero-extend random");
    end

    $display("──────────────────────────────────────────");
    $display("bit_extender testbench complete: %0d passed, %0d failed", pass_count, fail_count);
    if (fail_count == 0)
        $display("ALL TESTS PASSED");
    else
        $display("SOME TESTS FAILED — see errors above");
    $display("──────────────────────────────────────────");

    $finish;
end
endmodule
