module jump_unit (
    input logic Jump,
    input logic [25:0] JUMP_ADDR,
    input logic [31:0] PC_PLUS_4,
    output logic [31:0] PC_FINAL
);

always_comb begin
    PC_FINAL = {PC_PLUS_4[31:28], JUMP_ADDR, 2'b00};
    
end

endmodule