module decoder #(parameter WIDTH = 32)(
    input  logic [3:0] opcode,
    output logic       sub, direction, arithmetic,
    output logic [1:0] result
);

always_comb begin

    sub         = 1'b0;
    result      = 2'b00;
    direction   = 1'b0;
    arithmetic  = 1'b0;

    case (opcode)

        4'b0000: begin
            result = 2'b01; // AND
        end
        4'b0001: begin
            result = 2'b01; // OR
        end
        4'b0010: begin
            result    = 2'b01; // XOR
        end
        4'b0011: begin
            result    = 2'b01; // NOR
        end
        4'b0100: begin
            sub       = 1'b0;
            result    = 2'b00; // ADD
        end
        4'b0101: begin
            sub       = 1'b1;
            result    = 2'b00; // SUB
        end
        4'b0110: begin
            direction = 1'b0;
            result    = 2'b10; // LSL
        end
        4'b0111: begin
            direction = 1'b1;
            result    = 2'b10; // LSR
        end
        4'b1000: begin
            direction  = 1'b1;
            arithmetic = 1'b1;
            result     = 2'b10; // ASR
        end

        default: result = '0;
    endcase
end

endmodule
