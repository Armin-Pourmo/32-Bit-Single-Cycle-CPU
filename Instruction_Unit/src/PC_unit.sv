module PC_unit #(parameter WIDTH = 32)(
    input logic clk, rst, Branch, Zero, Jump, BranchNE,
    input logic [WIDTH-1:0]PC_BRANCH, PC_PLUS, PC_JUMP, 
    output logic [WIDTH-1:0]PC_OUT  
);

logic [WIDTH-1:0] Mux1, Mux2;

always_comb begin : BranchorPlus

    if(Branch && Zero)begin
        Mux1 = PC_BRANCH;
    end

    else if(BranchNE && !Zero)begin
        Mux1 = PC_BRANCH;
    end

    else begin
        Mux1 = PC_PLUS;
    end
end

always_comb begin : JumporNot

    if(Jump)begin
        Mux2 = PC_JUMP;
    end

    else begin
        Mux2 = Mux1;
    end
end


always_ff @(posedge clk) begin
    if (rst)
        PC_OUT <= '0;
    else
        PC_OUT <= Mux2;
    
end

endmodule