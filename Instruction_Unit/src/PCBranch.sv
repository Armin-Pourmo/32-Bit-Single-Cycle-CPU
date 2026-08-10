module PCBranch #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] EXTENDED_IMMEDIATE,PCPlus4,
    output logic [WIDTH-1:0] PC_JUMP
);

always_comb begin
    PC_JUMP = PCPlus4 + (EXTENDED_IMMEDIATE << 2);
end
endmodule