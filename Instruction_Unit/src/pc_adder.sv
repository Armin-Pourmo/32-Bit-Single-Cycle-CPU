module pc_adder #(parameter WIDTH = 32)(
    input  logic [WIDTH-1:0] PC,
    output logic [WIDTH-1:0] PC_NEXT
);

assign PC_next = PC + 32'd4;

endmodule
