module bit_extender #(parameter WIDTH = 32, IMM_WIDTH = 16)(
    input logic[IMM_WIDTH-1:0] immediate_var,
    output logic[WIDTH-1:0] extended_var
);

assign extended_var = {{(WIDTH-IMM_WIDTH){immediate_var[IMM_WIDTH-1]}}, immediate_var};

endmodule