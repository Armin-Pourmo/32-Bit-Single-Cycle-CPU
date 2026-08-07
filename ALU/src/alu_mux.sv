module alu_mux #(parameter WIDTH = 32)(
    input logic [WIDTH-1:0] RD2,
    input logic [WIDTH-1:0] EXTENDED_IMMEDIATE,
    input logic ALUSrc,
    output logic [WIDTH-1:0] ALU_INPUT2
);

always_comb begin
    if (ALUSrc)
        ALU_INPUT2 = EXTENDED_IMMEDIATE;
    else
        ALU_INPUT2 = RD2;
end
endmodule