module data_memory #(parameter WIDTH = 32, N = 65536)(
    input logic WE,clk,
    input logic [WIDTH-1:0] A,WD, //address
    output logic [WIDTH-1:0]RD
);

logic [7:0] mem [0:N-1];

assign RD = {mem[A+3], mem[A+2], mem[A+1], mem[A]};

always_ff @(posedge clk) begin
    if(WE == 1) begin
        mem[A]   <= WD[7:0];
        mem[A+1] <= WD[15:8];
        mem[A+2] <= WD[23:16];
        mem[A+3] <= WD[31:24];
    end
end
endmodule
