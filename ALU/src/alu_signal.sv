module alu_signal #(parameter WIDTH = 32)(
    input logic[2:0] operation,
    input logic[5:0] func,
    output logic [3:0] OPCODE
)

always_comb begin
    if(operation = 3'b)
