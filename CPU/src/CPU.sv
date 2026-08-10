module CPU #(parameter WIDTH = 32)(

    input logic clk,reset,
   
    
);

// Internal signals for instructions
logic [WIDTH-1:0] INSTR;
logic [WIDTH-1:0] PC_NEXT,PC_OUT,PC_JUMP; 
//PC_NEXT is the next sequential instruction address (PC+4), PC_OUT is the current instruction address, and PC_JUMP is the branch address calculated by the ALU.

//internal signals for decoded instruction
logic [5:0] OPCODE,FUNC;
logic [4:0] RS,RT,RD;
logic [15:0] IMMEDIATE;
logic [25:0] ADDR;

//register file signals
logic [WIDTH-1:0] RD1,RD2,WD3,EXTENDED_IMMEDIATE;
logic [4:0] WriteReg;

//MCU signals
logic MemtoReg,MemWrite,Branch,ALUSrc,RegDst,RegWrite;
logic [1:0] ALUOp; 

//ALU signals
logic [WIDTH-1:0] ALU_INPUT2,ALU_RESULT;

//Data Memory signals
logic [WIDTH-1:0] RD_MEM;

//----------------- ALU Flags ------------------
logic zero,sign,overflow,carry;

//--------------INSTRUCTION UNIT----------------
pc_register #(.WIDTH(WIDTH)) PC(
    .clk(clk),
    .rst(reset),
    .Branch(Branch),
    .Zero(zero),
    .PC_NEXT(PC_NEXT),
    .PC_JUMP(PC_JUMP),
    .PC_OUT(PC_OUT)
);

pc_adder #(.WIDTH(WIDTH)) PC_ADDER(
    .PC(PC_OUT),
    .PC_NEXT(PC_NEXT)
);

instruction_memory #(.WIDTH(WIDTH)) INSTRUCTION_MEMORY(
    .PC(PC_OUT),
    .INSTRUCTION(INSTR)
);

PCBranch #(.WIDTH(WIDTH)) PC_BRANCH(
    .EXTENDED_IMMEDIATE(EXTENDED_IMMEDIATE),
    .PCPlus4(PC_NEXT),
    .PC_JUMP(PC_JUMP)
);





//-----------Decoder Unit----------------
decoder_unit #(.WIDTH(WIDTH)) DECODER(
    .INSTRUCTION(INSTR),
    .RS(RS),
    .RT(RT),
    .RD(RD),
    .IMMEDIATE(IMMEDIATE),
    .OPCODE(OPCODE),
    .ADDR(ADDR),
    .FUNC(FUNC)
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
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc),
    .RegDst(RegDst),
    .RegWrite(RegWrite))






//-----------Register File----------------
register_file #(.WIDTH(WIDTH)) REG_FILE(
    .clk(clk),
    .rst(reset),
    .rst(reset),
    .WD3(WD3),
    .A1(RS),
    .A2(RT),
    .A3(WriteReg),

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
    .opcode(),
    .result(ALU_RESULT),
    .zero(zero),
    .sign(sign),
    .overflow(overflow),
    .carry(carry)
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