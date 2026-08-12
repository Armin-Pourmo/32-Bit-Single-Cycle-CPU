module PC_branch #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] EXTENDED_IMMEDIATE,PC_PLUS,
    output logic [WIDTH-1:0] PC_BRANCH
);

always_comb begin
    PC_BRANCH = PC_PLUS + (EXTENDED_IMMEDIATE << 2);
end
endmodule