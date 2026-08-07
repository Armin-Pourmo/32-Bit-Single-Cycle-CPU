/*
module alu_signal #(parameter WIDTH = 32)(
    input logic[2:0] OPERATOR,
    input logic[5:0] FUNC,
    output logic [3:0] ALU_OP,
    output logic VAR            // 1 = variable shift, 0 = immediate shift
)

//Func Codes
localparam SLL  = 6'b000000; // shift left logical
localparam SRL  = 6'b000010; // shift right logical
localparam SRA  = 6'b000011; // shift right arithmetic
//localparam SLLV = 6'b000100; // shift left logical variable
//localparam SRLV = 6'b000110; // shift right logical variable
//localparam SRAV = 6'b000111; // shift right arithmetic variable
localparam ADD  = 6'b100000; // add
localparam SUB  = 6'b100010; // subtract
localparam AND  = 6'b100100; // and
localparam OR   = 6'b100101; // or
localparam XOR  = 6'b100110; // xor
localparam NOR  = 6'b100111; // nor

//Copy Pasted ALU OPCODES from DECODER
localparam AND_OP = 4'b0000;
localparam OR_OP  = 4'b0001;
localparam XOR_OP = 4'b0010;
localparam NOR_OP = 4'b0011;
localparam ADD_OP = 4'b0100;   
localparam SUB_OP = 4'b0101;
localparam SLL_OP = 4'b0110;
localparam SRL_OP = 4'b0111;
localparam SRA_OP = 4'b1000;

always_comb begin
    if(OPERATOR == 2'b10 &&) begin
        case (FUNC)
            SLL:  begin ALU_OP = SLL_OP; VAR = 1'b0; end
            SRL:  begin ALU_OP = SRL_OP; VAR = 1'b0; end
            SRA:  begin ALU_OP = SRA_OP; VAR = 1'b0; end
//            SLLV: begin ALU_OP = SLL_OP; VAR = 1'b1; end
//            SRLV: begin ALU_OP = SRL_OP; VAR = 1'b1; end
//            SRAV: begin ALU_OP = SRA_OP; VAR = 1'b1; end
            ADD:  begin ALU_OP = ADD_OP; VAR = 1'b0; end
            SUB:  begin ALU_OP = SUB_OP; VAR = 1'b0; end
            AND:  begin ALU_OP = AND_OP; VAR = 1'b0; end
            OR:   begin ALU_OP = OR_OP; VAR = 1'b0; end
            XOR:  begin ALU_OP = XOR_OP; VAR = 1'b0; end
            NOR:  begin ALU_OP = NOR_OP; VAR = 1'b0; end

            default: begin ALUOP = '0; VAR = '0; end
        endcase
    

        
*/


 