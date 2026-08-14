module CPU #(parameter WIDTH = 32)(

    input logic clk,reset,
    output logic [WIDTH-1:0] TEST_PC_OUT,TEST_INSTR,TEST_ALU_RESULT,TEST_RD_MEM //Outputs for testing purposes
);

always_comb begin : blockName

    if(reset) begin
        TEST_PC_OUT = '0;
        TEST_INSTR = '0;
        TEST_ALU_RESULT = '0;
        TEST_RD_MEM = '0;
    end
    else begin
        TEST_PC_OUT = PC_OUT;
        TEST_INSTR = INSTR;
        TEST_ALU_RESULT = ALU_RESULT;
        TEST_RD_MEM = RD_MEM;
    end
end


// Internal signals for instructions
logic [WIDTH-1:0] INSTR;
logic [WIDTH-1:0] PC_BRANCH, PC_PLUS, PC_JUMP, PC_OUT; 
//PC_NEXT is the next sequential instruction address (PC+4), PC_OUT is the current instruction address, and PC_JUMP is the branch address calculated by the ALU.

//internal signals for decoded instruction
logic [5:0] OPCODE,FUNC;
logic [4:0] RS,RT,RD;
logic [15:0] IMMEDIATE;
logic [25:0] JUMP_ADDR;

//register file signals
logic [WIDTH-1:0] RD1,RD2,WD3,EXTENDED_IMMEDIATE;
logic [4:0] WriteReg;

//MCU signals
logic MemtoReg,MemWrite,Branch,ALUSrc,RegDst,RegWrite,Jump;
logic [1:0] ALUOp; 
logic [3:0] ALUControl;

//ALU signals
logic [WIDTH-1:0] ALU_INPUT2,ALU_RESULT;
logic [4:0] SHAMT; //shamt signal for ALU

//Data Memory signals
logic [WIDTH-1:0] RD_MEM;

//----------------- ALU Flags ------------------
logic zero,sign,overflow,carry;

//--------------INSTRUCTION UNIT----------------
PC_unit #(.WIDTH(WIDTH)) PC_UNIT(
    .clk(clk),
    .rst(reset),
    .Branch(Branch),
    .BranchNE(BranchNE),
    .Zero(zero),
    .Jump(Jump),
    .PC_BRANCH(PC_BRANCH),
    .PC_PLUS(PC_PLUS),
    .PC_JUMP(PC_JUMP),

    .PC_OUT(PC_OUT)
);

PC_plus #(.WIDTH(WIDTH)) PC_PLUS_UNIT(
    .PC(PC_OUT),
    .PC_PLUS(PC_PLUS)
);

PC_jump #(.WIDTH(WIDTH)) PC_JUMP_UNIT(
    .JUMP_ADDR(JUMP_ADDR),
    .PC_PLUS(PC_PLUS),
    .PC_JUMP(PC_JUMP)
);

PC_branch #(.WIDTH(WIDTH)) PC_BRANCH_UNIT(
    .EXTENDED_IMMEDIATE(EXTENDED_IMMEDIATE),
    .PC_PLUS(PC_PLUS),
    .PC_BRANCH(PC_BRANCH)
);


instruction_memory #(.WIDTH(WIDTH)) INSTRUCTION_MEMORY(
    .PC(PC_OUT),
    .INSTRUCTION(INSTR)
);


//-----------Decoder Unit----------------
decoder_unit #(.WIDTH(WIDTH)) DECODER(
    .INSTRUCTION(INSTR),
    .RS(RS),
    .RT(RT),
    .RD(RD),
    .IMMEDIATE(IMMEDIATE),
    .OPCODE(OPCODE),
    .FUNC(FUNC),
    .SHIFT_AMNT(SHAMT),
    .JUMP_ADDR(JUMP_ADDR)
);

bit_extender #(.WIDTH(WIDTH)) BIT_EXTENDER(
    .immediate_var(IMMEDIATE),
    .extended_var(EXTENDED_IMMEDIATE)
);

MCU #(.WIDTH(WIDTH)) MCU(
    .OPCODE(OPCODE),

    .MemtoReg(MemtoReg),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .BranchNE(BranchNE),
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc),
    .RegDst(RegDst),
    .RegWrite(RegWrite),
    .Jump(Jump)
);

ALUDecoder #(.WIDTH(WIDTH)) ALU_DECODER(
    .ALUOp(ALUOp),
    .FUNC(FUNC),
    .ALUControl(ALUControl)
);






//-----------Register File----------------
register_file #(.WIDTH(WIDTH)) REG_FILE(
    .clk(clk),
    .rst(reset),
    .WD3(WD3),
    .A1(RS),
    .A2(RT),
    .A3(WriteReg),
    .enable(RegWrite),

    .RD1(RD1),
    .RD2(RD2)
);

MCU_mux #(.WIDTH(WIDTH)) MCU_MUX(
    .RegDst(RegDst),
    .RT(RT),
    .RD(RD),
    .A3(WriteReg)
);

//-----------ALU----------------



alu #(.WIDTH(WIDTH)) ALU(
    .a(RD1),
    .b(ALU_INPUT2),
    .shval(RD2),
    .opcode(ALUControl),
    .result(ALU_RESULT),
    .zero(zero),
    .sign(sign),
    .overflow(overflow),
    .carry(carry),
    .shamt(SHAMT)
);

alu_mux #(.WIDTH(WIDTH)) ALU_MUX(
    .RD2(RD2),
    .EXTENDED_IMMEDIATE(EXTENDED_IMMEDIATE),
    .ALUSrc(ALUSrc),
    .ALU_INPUT2(ALU_INPUT2)
);




//-----------Data Memory----------------
data_memory #(.WIDTH(WIDTH)) DATA_MEMORY(
    .clk(clk),
    .rst(reset),
    .A(ALU_RESULT),
    .WD(RD2),
    .WE(MemWrite),
    .RD(RD_MEM)
);

read_data_mux #(.WIDTH(WIDTH)) READ_DATA_MUX(
    .ALU_RESULT(ALU_RESULT),
    .MEM_READ_DATA(RD_MEM),
    .MemtoReg(MemtoReg),
    .WD3(WD3)
);

endmodule