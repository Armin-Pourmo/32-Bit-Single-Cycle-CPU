module instruction_memory #(parameter WIDTH = 32, IMM_WIDTH = 16, STORAGE = 256) (
    
    input logic [WIDTH-1:0] PC,
    output logic [WIDTH-1:0]INSTRUCTION
    
);

logic [WIDTH-1:0] INSTR_MEM [0:STORAGE-1];


assign INSTRUCTION = INSTR_MEM[PC];

endmodule