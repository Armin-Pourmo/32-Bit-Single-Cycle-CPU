module PC_jump #(parameter WIDTH = 32)(
    input logic [25:0] JUMP_ADDR,
    input logic [31:0] PC_PLUS,
    output logic [31:0] PC_JUMP
);

assign PC_JUMP = {PC_PLUS[31:28], JUMP_ADDR, 2'b00};

endmodule