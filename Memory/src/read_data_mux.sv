module read_data_mux #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] ALU_RESULT,
    input logic [15:0] IMM,
    input logic [WIDTH-1:0] MEM_READ_DATA,
    input logic MemtoReg,LU,
    output logic [WIDTH-1:0] WD3
);

always_comb begin
    if (MemtoReg)
        WD3 = MEM_READ_DATA;
    else if(LU)
        WD3 = {IMM[15:0], 16'b0};
    else
        WD3 = ALU_RESULT;
end
endmodule