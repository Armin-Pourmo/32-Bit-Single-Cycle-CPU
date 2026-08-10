module pc_register #(parameter WIDTH = 32)(
    input logic clk,
    input logic rst,PCSrc,
    input logic[WIDTH-1:0] PC_NEXT,PC_JUMP,
    output logic[WIDTH-1:0] PC_OUT
);

always_ff @(posedge clk) begin
    if (rst)
        PC_OUT <= '0;
    else if (PCSrc)
        PC_OUT <= PC_JUMP;
    else
        PC_OUT <= PC_NEXT;
end

endmodule