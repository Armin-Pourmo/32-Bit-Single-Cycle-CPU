module PCSrc (
    input logic Branch,zero,
    output logic PCSrc
)

always_comb begin
    if(Branch && zero) begin
        PCSrc = 1'b1;
    end else begin
        PCSrc = 1'b0;
    end
end