module PC_unit #(parameter WIDTH = 32)(
    input logic clk, rst, Branch, Zero, Jump, BranchNE, JR,
    input logic [WIDTH-1:0]PC_BRANCH, PC_PLUS, PC_JUMP, RD,
    output logic [WIDTH-1:0]PC_OUT  
);

logic [WIDTH-1:0] Mux1;

always_comb begin : BranchorPlus

    if(Branch && Zero)begin
        Mux1 = PC_BRANCH;
    end

    else if(BranchNE && !Zero)begin
        Mux1 = PC_BRANCH;
    end

    else if(JR)begin
        Mux1 = RD;
    end

    else if(Jump)begin
        Mux1 = PC_JUMP;
    end

    else begin
        Mux1 = PC_PLUS;
    end
end


always_ff @(posedge clk) begin
    if (rst)
        PC_OUT <= '0;
    else
        PC_OUT <= Mux1;
    
end

endmodule