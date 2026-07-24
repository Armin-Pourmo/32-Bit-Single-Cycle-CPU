module logic_unit #(parameter WIDTH = 32) (
    input logic [WIDTH - 1:0] a , b,
    input logic [3:0] opcode,
    output logic [WIDTH - 1:0] result
);

logic [WIDTH-1:0]y_and,y_or,y_xor,y_nor;

always_comb begin : logicUnits

    y_and = a & b;
    y_or = a | b;
    y_xor = a ^ b;
    y_nor = ~(a | b);

    case (opcode[1:0])
        2'b00: result = y_and;
        2'b01: result = y_or;
        2'b10: result = y_xor;
        2'b11: result = y_nor;
        default: result = '0;
    endcase
end

endmodule