module MCU_mux #(parameter WIDTH = 32)(
    input logic RegDst,
    input logic [4:0] RT,RD,
    output logic [4:0] A3
);

always_comb begin
    if (RegDst)
        A3 = RD;
    else
        A3 = RT;
end
endmodule