module add_subtract_unit #(parameter WIDTH = 32) (
    input logic [WIDTH - 1:0] a, b,
    input logic  sub,
    output logic [WIDTH - 1:0] sum,
    output logic cout,zero_flag,sign_flag,overflow_flag
);

logic [WIDTH - 1:0] inv_b;
logic [WIDTH:0] carry;

assign inv_b = b ^ {WIDTH{sub}};
assign carry[0] = sub;
assign cout = carry[WIDTH];
assign zero_flag = ~|sum;
assign sign_flag = sum[WIDTH - 1];
assign overflow_flag = carry[WIDTH-1] ^ carry[WIDTH];


genvar i;
generate
    for (i = 0; i < WIDTH; i++) begin : adder_chain
        full_adder fa (
            .a(a[i]),
            .b(inv_b[i]),
            .cin (carry[i]),
            .sum(sum[i]),
            .cout(carry[i+1])
        );
    end

endgenerate
endmodule