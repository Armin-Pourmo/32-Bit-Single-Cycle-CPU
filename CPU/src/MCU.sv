module MCU #(parameter WIDTH = 32)(
    input  logic [5:0] OPCODE,
    input logic[5:0] FUNC,

    output logic       RegDst,
    output logic       ALUSrc,
    output logic       MemToReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic       BranchNE,   // 0 = beq polarity, 1 = bne polarity
    output logic       Jump,
    output logic       ExtOp,      // 0 = sign-extend, 1 = zero-extend
    output logic       ForceZeroA, // 1 = force ALU's a-input to 0 (lui)
    output logic [1:0] ALUOp
);

// Opcodes
localparam OP_RTYPE = 6'b000000;
localparam OP_LW    = 6'h23;
localparam OP_SW    = 6'h2B;
localparam OP_BEQ   = 6'h04;
localparam OP_BNE   = 6'h05;
localparam OP_ADDI  = 6'h08;
localparam OP_SLTI  = 6'h0A;
localparam OP_ANDI  = 6'h0C;
localparam OP_ORI   = 6'h0D;
localparam OP_XORI  = 6'h0E;
localparam OP_LUI   = 6'h0F;
localparam OP_J     = 6'b000010;
localparam OP_JAL   = 6'b000011;

always_comb begin
    // Defaults — safe/inactive for every control signal
    RegDst     = 1'b0;
    ALUSrc     = 1'b0;
    MemToReg   = 1'b0;
    RegWrite   = 1'b0;
    MemRead    = 1'b0;
    MemWrite   = 1'b0;
    Branch     = 1'b0;
    BranchNE   = 1'b0;
    Jump       = 1'b0;
    ExtOp      = 1'b0;
    ForceZeroA = 1'b0;
    ALUOp      = 2'b00;

    case (OPCODE)

        OP_RTYPE: begin
            RegDst   = 1'b1;
            RegWrite = 1'b1;
            ALUOp    = 2'b10; // look at FUNC
        end

        OP_LW: begin
            ALUSrc   = 1'b1;
            MemToReg = 1'b1;
            RegWrite = 1'b1;
            MemRead  = 1'b1;
            ALUOp    = 2'b00; // add
        end

        OP_SW: begin
            ALUSrc    = 1'b1;
            MemWrite  = 1'b1;
            ALUOp     = 2'b00; // add
        end

        OP_BEQ: begin
            Branch   = 1'b1;
            BranchNE = 1'b0;
            ALUOp    = 2'b01; // subtract, check zero
        end

        OP_BNE: begin
            Branch   = 1'b1;
            BranchNE = 1'b1;
            ALUOp    = 2'b01; // subtract, check zero
        end

        OP_ADDI: begin
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            ALUOp    = 2'b00; // add
        end

        OP_SLTI: begin
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            ALUOp    = 2'b11; // set-less-than (needs a mapped ALUOp case in alu_control)
        end

        OP_ANDI: begin
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            ExtOp    = 1'b1; // zero-extend
            ALUOp    = 2'b10; // reuse funct-style lookup, or dedicated case in alu_control
        end

        OP_ORI: begin
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            ExtOp    = 1'b1; // zero-extend
            ALUOp    = 2'b10;
        end

        OP_XORI: begin
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            ExtOp    = 1'b1; // zero-extend
            ALUOp    = 2'b10;
        end

        OP_LUI: begin
            ALUSrc     = 1'b1;
            RegWrite   = 1'b1;
            ForceZeroA = 1'b1; // ALU's a-input forced to 0, result = immediate<<16
            ALUOp      = 2'b10;
        end

        OP_J: begin
            Jump = 1'b1;
        end

        // TODO: jal writes PC+4 into $ra (register 31) — this needs a third
        // writeback source (not ALU result, not memory read) that none of the
        // current muxes support yet. RegDst/RegWrite behavior for forcing the
        // write register to 31 also isn't handled. Revisit once the
        // MemToReg/writeback mux is designed.
        OP_JAL: begin
            Jump = 1'b1;
        end

        default: begin
            // leave all defaults (safe/inactive)
        end

    endcase
end

endmodule
