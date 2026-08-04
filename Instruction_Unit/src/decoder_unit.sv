module decoder_unit #(parameter WIDTH = 32, RTYPE = 5, SHAMT = 5, FUNCT = 6, IMM = 16 ) (
    input logic [WIDTH-1:0] INSTRUCTION,
    output logic [RTYPE-1:0] RS,RT,RD,
    output logic [SHAMT-1:0]SHIFT_AMNT,
    output logic [FUNCT-1:0] FUNC,
    output logic [IMM-1:0]IMMEDIATE,
    output logic [5:0] OPCODE,
    output logic[25:0]ADDR
);





always @(*) begin

    OPCODE = INSTRUCTION[31:26];

    {RS, RT, RD} = '0;
    SHIFT_AMNT = '0;
    FUNC = '0;
    IMMEDIATE = '0;
    ADDR = '0;

    //r-type
    if(OPCODE == 6'd0) begin

        RS = INSTRUCTION[25:21];          
        RT = INSTRUCTION[20:16];
        RD = INSTRUCTION[15:11];
        SHIFT_AMNT = INSTRUCTION[10:6];
        FUNC = INSTRUCTION[5:0];
    end
    //j-type
    else if ((OPCODE[1:0]!=2'b00) && (OPCODE[5:2] == 4'b0000)) begin
        ADDR = INSTRUCTION[25:0];
        

    end

    //i-type
    else begin
        RS = INSTRUCTION[25:21];         
        RT = INSTRUCTION[20:16];
        IMMEDIATE = INSTRUCTION[15:0];
        
    end
end

endmodule

        
        
    

