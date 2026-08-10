module pc_register #(parameter WIDTH = 32)(
    input logic clk,rst,Branch,Zero
    input logic [WIDTH-1:0] PC_NEXT,PC_JUMP,
    output logic [WIDTH-1:0] PC_OUT
);
//PC_JUMP is the branch address calculated by the ALU, PC_NEXT is the next sequential instruction address (PC+4), and PC_OUT is the current instruction address.


always_ff @(posedge clk) begin
    if (rst)
        PC_OUT <= '0;
    else if (Branch && Zero)
        PC_OUT <= PC_JUMP;
    else
        PC_OUT <= PC_NEXT;
end

endmodule