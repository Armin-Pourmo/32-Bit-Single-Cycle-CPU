module ALUDecoder #(parameter WIDTH = 32)(
    input logic [3:0] ALUControl_MCU, // Original ALUControl from MCU. May or may not be changed in this module
    input logic [1:0] ALUOp,
    input logic [5:0] FUNC,
    output logic [3:0] ALUControl,
    output logic JR // New output signal to indicate if the instruction is a JR instruction
    
);

//------------------FUNC Control Signals----------------

localparam FUNC_SLL = 6'b000000;
localparam FUNC_SRL = 6'b000010;
localparam FUNC_SRA = 6'b000011;
localparam FUNC_ADD = 6'b100000;
localparam FUNC_SUB = 6'b100010;
localparam FUNC_AND = 6'b100100;
localparam FUNC_OR  = 6'b100101;
localparam FUNC_XOR = 6'b100110;
localparam FUNC_NOR = 6'b100111;
localparam FUNC_SLT = 6'b101010;
localparam FUNC_JR  = 6'b001000;

//------------------ALU Control Signals-----------------
localparam AND = 4'b0000;
localparam OR  = 4'b0001;
localparam XOR = 4'b0010;
localparam NOR = 4'b0011;
localparam ADD = 4'b0100;   
localparam SUB = 4'b0101;
localparam SLL = 4'b0110;
localparam SRL = 4'b0111;
localparam SRA = 4'b1000;
localparam SLT = 4'b1010;



always_comb begin
    JR = 1'b0; // Default value for JR signal
    ALUControl = 4'bxxxx; // Default value for ALUControl
    case(ALUOp)
        2'b00: ALUControl = ADD; // ADD
        2'b01: ALUControl = SUB; // SUB
        2'b11: ALUControl = ALUControl_MCU; // Use ALUControl from MCU
        2'b10: begin
            case(FUNC)
                FUNC_SLL: ALUControl = SLL;
                FUNC_SRL: ALUControl = SRL;
                FUNC_SRA: ALUControl = SRA;
                FUNC_ADD: ALUControl = ADD;
                FUNC_SUB: ALUControl = SUB;
                FUNC_AND: ALUControl = AND;
                FUNC_OR : ALUControl = OR;
                FUNC_XOR: ALUControl = XOR;
                FUNC_NOR: ALUControl = NOR;
                FUNC_SLT: ALUControl = SLT;
                FUNC_JR: JR = 1'b1; // JR instruction
                default: ALUControl = 4'bxxxx; // Undefined
            endcase
        end
        default: ALUControl = 4'bxxxx; // Undefined
    endcase
end

endmodule