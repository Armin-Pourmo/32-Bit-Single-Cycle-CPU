module shift_unit #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] data,
    input  logic [4:0]       shamt,
    input  logic             direction,
    input  logic             arithmetic,
    output logic [WIDTH-1:0] result
);

always_comb begin
    case ({direction, arithmetic})
        2'b00: result = data << shamt;
        2'b01: result = data << shamt;
        2'b10: result = data >> shamt;
        2'b11: result = $signed(data) >>> shamt;
        default: result = '0;
    endcase
end

endmodule
