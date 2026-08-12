module decoder_unit #(parameter WIDTH = 32, RTYPE = 5, SHAMT = 5, FUNCT = 6, IMM = 16 ) (
    input logic [WIDTH-1:0] INSTRUCTION,
    output logic [RTYPE-1:0] RS,RT,RD,
    output logic [SHAMT-1:0]SHIFT_AMNT,
    output logic [FUNCT-1:0] FUNC,
    output logic [IMM-1:0]IMMEDIATE,
    output logic [5:0] OPCODE,
    output logic[25:0]JUMP_ADDR
);





always @(*) begin

    OPCODE = INSTRUCTION[31:26];


    //r-type
    RS = INSTRUCTION[25:21];          
    RT = INSTRUCTION[20:16];
    RD = INSTRUCTION[15:11];
    SHIFT_AMNT = INSTRUCTION[10:6];
    FUNC = INSTRUCTION[5:0];


    //i-type
    IMMEDIATE = INSTRUCTION[15:0];

    //j-type
    JUMP_ADDR = INSTRUCTION[25:0];

end

endmodule

        
        
    

