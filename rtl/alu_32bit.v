// =============================================================================
// File        : alu_32bit.v
// Module      : alu_32bit
// Description : 32-bit Arithmetic Logic Unit — the power-managed functional
//               block. Supports 9 operations. The 'en' input is monitored by
//               the activity monitor to detect idle periods for power gating.
//               When iso_en is asserted (power domain isolating), result is
//               clamped to 0 via isolation logic in the top-level.
// Reference   : p5 (Chang 2012) — ALU used as benchmark for power gating.
// =============================================================================

module alu_32bit (
    input  wire        clk,       // System clock
    input  wire        rst,       // Synchronous active-high reset
    input  wire        en,        // Enable: 1 = ALU requested this cycle
    input  wire [3:0]  op,        // Operation select (see encoding below)
    input  wire [31:0] a,         // Operand A
    input  wire [31:0] b,         // Operand B
    output reg  [31:0] result,    // Computed result (registered output)
    output reg         valid,     // 1 cycle after en: result is valid
    output wire        alu_active // Combinational: en & (op != NOP)
);

    // -------------------------------------------------------------------------
    // Operation encoding
    // -------------------------------------------------------------------------
    localparam OP_ADD  = 4'b0000;  // result = a + b
    localparam OP_SUB  = 4'b0001;  // result = a - b
    localparam OP_AND  = 4'b0010;  // result = a & b
    localparam OP_OR   = 4'b0011;  // result = a | b
    localparam OP_XOR  = 4'b0100;  // result = a ^ b
    localparam OP_NOT  = 4'b0101;  // result = ~a
    localparam OP_SHL  = 4'b0110;  // result = a << b[4:0]
    localparam OP_SHR  = 4'b0111;  // result = a >> b[4:0]
    localparam OP_PASS = 4'b1000;  // result = a (pass-through)
    localparam OP_NOP  = 4'b1111;  // No operation (idle)

    // -------------------------------------------------------------------------
    // Combinational result computation
    // -------------------------------------------------------------------------
    reg [31:0] comb_result;

    always @(*) begin
        case (op)
            OP_ADD  : comb_result = a + b;
            OP_SUB  : comb_result = a - b;
            OP_AND  : comb_result = a & b;
            OP_OR   : comb_result = a | b;
            OP_XOR  : comb_result = a ^ b;
            OP_NOT  : comb_result = ~a;
            OP_SHL  : comb_result = a << b[4:0];
            OP_SHR  : comb_result = a >> b[4:0];
            OP_PASS : comb_result = a;
            default  : comb_result = 32'b0;
        endcase
    end

    // -------------------------------------------------------------------------
    // Output registers: capture on clock edge when enabled
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            result <= 32'b0;
            valid  <= 1'b0;
        end else if (en && (op != OP_NOP)) begin
            result <= comb_result;
            valid  <= 1'b1;
        end else begin
            valid  <= 1'b0;
        end
    end

    // -------------------------------------------------------------------------
    // Activity indicator: combinational, used by activity monitor
    // -------------------------------------------------------------------------
    assign alu_active = en && (op != OP_NOP);

endmodule
