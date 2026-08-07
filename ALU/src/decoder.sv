module decoder #(parameter WIDTH = 32)(
    input  logic [3:0] opcode,
    output logic       sub, direction, arithmetic,
    output logic [1:0] result
);

localparam AND = 4'b0000;
localparam OR  = 4'b0001;
localparam XOR = 4'b0010;
localparam NOR = 4'b0011;
localparam ADD = 4'b0100;   
localparam SUB = 4'b0101;
localparam SLL = 4'b0110;
localparam SRL = 4'b0111;
localparam SRA = 4'b1000;

always_comb begin

    sub         = 1'b0;
    result      = 2'b00;
    direction   = 1'b0;
    arithmetic  = 1'b0;

    case (opcode)

        AND: begin
            result = 2'b01; // AND
        end
        OR: begin
            result = 2'b01; // OR
        end
        XOR: begin
            result    = 2'b01; // XOR
        end
        NOR: begin
            result    = 2'b01; // NOR
        end
        ADD: begin
            sub       = 1'b0;
            result    = 2'b00; // ADD
        end
        SUB: begin
            sub       = 1'b1;
            result    = 2'b00; // SUB
        end
        SLL: begin
            direction = 1'b0;
            result    = 2'b10; // SLL
        end
        SRL: begin
            direction = 1'b1;
            result    = 2'b10; // SRL
        end
        SRA: begin
            direction  = 1'b1;
            arithmetic = 1'b1;
            result     = 2'b10; // SRA
        end

        default: result = '0;
    endcase
end

endmodule
