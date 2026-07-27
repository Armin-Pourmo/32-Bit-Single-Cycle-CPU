module register_file #(parameter N = 32, WIDTH = 32)(
    input logic clk, enable,
    input logic [WIDTH-1:0] WD3,
    input logic [WIDTH-1:0] A1, A2, A3,
    output logic [WIDTH-1:0] RD1, RD2
);

    logic [WIDTH-1:0] mem [0:N-1];

    always_ff @(posedge clk) begin
        if (enable && A3 != 0)
            mem[A3] <= WD3;
    
    end

    assign RD1 = (A1 == 0) ? '0 : mem[A1];
    assign RD2 = (A2 == 0) ? '0 : mem[A2];


endmodule
