module pc_register #(parameter WIDTH = 32)(
    input logic clk,rst,Branch,Zero,Jump,
    input logic [WIDTH-1:0] PC_NEXT,PC_JUMP,PC_JUMP_TARGET,
    output logic [WIDTH-1:0] PC_OUT
);
//PC_JUMP is the branch address calculated by the ALU, PC_NEXT is the next sequential instruction address (PC+4),
//PC_JUMP_TARGET is the J-type jump target, and PC_OUT is the current instruction address.


always_ff @(posedge clk) begin
    if (rst)
        PC_OUT <= '0;
    else if (Jump)
        PC_OUT <= PC_JUMP_TARGET;
    else if (Branch && Zero)
        PC_OUT <= PC_JUMP;
    else
        PC_OUT <= PC_NEXT;
end

endmodule