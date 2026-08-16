module read_data_mux #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] ALU_RESULT,
    input logic [15:0] IMM,
    input logic [WIDTH-1:0] MEM_READ_DATA,PC_PLUS,
    input logic MemtoReg,LU,JAL,
    output logic [WIDTH-1:0] WD3
);

always_comb begin
    if (MemtoReg)
        WD3 = MEM_READ_DATA;
    else if(LU)
        WD3 = {IMM[15:0], 16'b0};
    else if(JAL)
        WD3 = PC_PLUS;
    
    else
        WD3 = ALU_RESULT;
end
endmodule