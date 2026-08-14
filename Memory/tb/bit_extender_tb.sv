module bit_extender_tb;
localparam WIDTH     = 32;
localparam IMM_WIDTH = 16;

logic [IMM_WIDTH-1:0]    immediate_var;
logic [WIDTH-1:0]        extended_var;

bit_extender #(.WIDTH(WIDTH), .IMM_WIDTH(IMM_WIDTH)) dut (
    .immediate_var(immediate_var),
    .extended_var(extended_var)
);

task check(
    input logic [WIDTH-1:0] expected,
    input string            label
);
    #5;
    if (extended_var === expected)
        $display("PASS [%s] imm=%h | extended=%h", label, immediate_var, extended_var);
    else
        $error("FAIL [%s] imm=%h | expected=%h got=%h", label, immediate_var, expected, extended_var);
endtask

initial begin
    $dumpfile("dump/bit_extender.vcd");
    $dumpvars(0, bit_extender_tb);

    // ── Sign extend (the module's only mode) ───────────────────────────
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

    $display("All bit_extender tests complete");
    $finish;
end
endmodule
