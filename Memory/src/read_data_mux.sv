module read_data_mux #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] ALU_RESULT,
    input logic [WIDTH-1:0] MEM_READ_DATA,
    input logic MemtoReg,
    output logic [WIDTH-1:0] WD3
);

always_comb begin
    if (MemtoReg)
        WD3 = MEM_READ_DATA;
    else
        WD3 = ALU_RESULT;
end
endmodule