module bit_extender #(parameter WIDTH = 32, IMM_WIDTH = 16)(
    input logic[IMM_WIDTH-1:0] immediate_var,
    output logic[WIDTH-1:0] extended_var
);


always_comb begin : bit_extender

    extended_var[WIDTH-1:IMM_WIDTH] = immediate_var[IMM_WIDTH-1];
    extended_var[IMM_WIDTH-1:0]=immediate_var[IMM_WIDTH-1:0];
end
endmodule