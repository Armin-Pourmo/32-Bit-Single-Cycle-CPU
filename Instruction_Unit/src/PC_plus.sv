module PC_plus #(parameter WIDTH = 32)(
    input  logic [WIDTH-1:0] PC,
    output logic [WIDTH-1:0] PC_PLUS
);

assign PC_PLUS = PC + 32'd4;

endmodule
