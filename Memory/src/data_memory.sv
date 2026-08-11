module data_memory #(parameter WIDTH = 32, N = 65536)(
    input logic WE,clk,rst,
    input logic [WIDTH-1:0] WD,
    input logic [15:0] A, //address
    output logic [WIDTH-1:0]RD
);

logic [7:0] mem [0:N-1];

assign RD = {mem[A+3], mem[A+2], mem[A+1], mem[A]};

always_ff @(posedge clk) begin
    if(rst) begin
        for(int i = 0; i < N; i++) begin
            mem[i] <= 8'b0;
        end
    end
    else
    if(WE == 1) begin
        mem[A]   <= WD[7:0];
        mem[A+1] <= WD[15:8];
        mem[A+2] <= WD[23:16];
        mem[A+3] <= WD[31:24];
    end
end
endmodule
