module MCU #(parameter WIDTH = 32)(
    input  logic [5:0] OPCODE,
    
    output logic MemtoReg,
    output logic MemWrite,
    output logic Branch,BranchNE,
    output logic [1:0] ALUOp,
    output logic ALUSrc,
    output logic RegDst,
    output logic RegWrite,
    output logic Jump

);

    // OPCODE values for each instruction type
    localparam OP_RTYPE = 6'b000000;
    localparam OP_LW    = 6'b100011;
    localparam OP_SW    = 6'b101011;
    localparam OP_BEQ   = 6'b000100;
    localparam OP_ADDI  = 6'b001000;
    localparam OP_JUMP  = 6'b000010;
    localparam OP_BNE   = 6'b000101;
    
    // Defaults — safe/inactive for every control signal
always_comb begin
    MemtoReg = 1'b0;
    MemWrite = 1'b0;
    Branch   = 1'b0;
    BranchNE = 1'b0;
    ALUOp    = 2'b00;
    ALUSrc   = 1'b0;
    RegDst   = 1'b0;
    RegWrite = 1'b0;
    Jump     = 1'b0;

    case (OPCODE)

        OP_RTYPE: begin
            RegDst   = 1'b1;
            RegWrite = 1'b1;
            ALUOp    = 2'b10; // look at FUNC
        end

        OP_LW: begin
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            MemtoReg = 1'b1;

        end

        OP_SW: begin
            ALUSrc    = 1'b1;
            MemWrite  = 1'b1;
            ALUOp     = 2'b00; // add
        end

        OP_BEQ: begin
            Branch   = 1'b1;
            ALUOp    = 2'b01; // subtract, check zero
        end
    
        OP_ADDI: begin
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            ALUOp    = 2'b00; // look at FUNC
        end

        OP_JUMP: begin
            Jump = 1'b1;
        end

        OP_BNE: begin
            BranchNE = 1'b1;
            ALUOp    = 2'b01; // subtract, check zero
        end

    endcase
end

endmodule
