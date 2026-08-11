module alu #(parameter WIDTH = 32)(

    input logic [WIDTH-1:0]     a,b,
    input logic [3:0]           opcode,
    input logic [4:0]           shamt,
    input logic [WIDTH-1:0]     shval,
    output logic [WIDTH-1:0]    result,

    output logic                zero,sign,overflow,carry

) ;

logic [WIDTH-1:0] result_add,result_shift,result_logic;
logic [1:0] operation;
logic sub,direction,arithmetic;

decoder #(.WIDTH(WIDTH)) decode(
    .opcode(opcode),
    .result(operation),
    .sub(sub),
    .direction(direction),
    .arithmetic(arithmetic)
);

add_subtract_unit #(.WIDTH(WIDTH)) ALU_ADD(
    .a(a),
    .b(b),
    .sum(result_add),
    .sub(sub),
    .cout(carry),
    .zero_flag(zero),
    .sign_flag(sign),
    .overflow_flag(overflow)
);

logic_unit #(.WIDTH(WIDTH)) ALU_LOGIC(
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(result_logic)
);

shift_unit #(.WIDTH(WIDTH)) ALU_SHIFT(
    .direction(direction),
    .arithmetic(arithmetic),

    .data(shval),
    .shamt(shamt),
    .result(result_shift)

);

always_comb begin: final_mux
    case(operation)

        2'b00: result = result_add;
        2'b01: result = result_logic;
        2'b10: result = result_shift;
        default: result = result_add;
    endcase
end

endmodule