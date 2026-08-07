module pc_mux #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] PC_PLUS_4,
    input logic [WIDTH-1:0] BRANCH_ADDR,
    input logic BRANCH_TAKEN,
    output logic [WIDTH-1:0] PC_RESULT
);

always_comb begin
    if (BRANCH_TAKEN)
        PC_RESULT = BRANCH_ADDR;
    else
        PC_RESULT = PC_PLUS_4;
end

endmodule
