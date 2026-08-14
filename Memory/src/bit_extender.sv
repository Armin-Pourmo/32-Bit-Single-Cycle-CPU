module bit_extender #(parameter WIDTH = 32, IMM_WIDTH = 16)(
    input logic EXT_Op,
    input logic[IMM_WIDTH-1:0] immediate_var,
    output logic[WIDTH-1:0] extended_var
);

always_comb begin
    if (!EXT_Op) begin
        extended_var = {{(WIDTH-IMM_WIDTH){immediate_var[IMM_WIDTH-1]}}, immediate_var};
    end else begin
        extended_var = {{(WIDTH-IMM_WIDTH){1'b0}}, immediate_var};
    end
end



endmodule