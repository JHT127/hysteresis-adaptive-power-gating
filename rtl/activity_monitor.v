// =============================================================================
// File        : activity_monitor.v
// Module      : activity_monitor
// Description : Monitors the ALU activity signal over a rolling window of
//               WINDOW_SIZE cycles. Computes:
//                 - idle_count    : consecutive cycles with no ALU activity
//                 - activity_rate : fraction of the last WINDOW_SIZE cycles
//                                   that had activity (scaled 0–255 for 8-bit)
//                 - is_idle       : 1 when current cycle has no ALU activity
//
//               The rolling window is implemented as a shift register of bits
//               (WINDOW_SIZE = 16) and a popcount of those bits, which requires
//               only flip-flops and adder logic — zero multipliers.
//
// Technique   : Derived from p1 (Karthikeyan) workload monitoring concept,
//               simplified from ML/decision-tree to shift-register popcount
//               for minimal area overhead.
// =============================================================================

module activity_monitor #(
    parameter WINDOW_SIZE = 16,    // Rolling window in cycles (power of 2)
    parameter IDLE_MAX    = 255    // Saturating idle counter ceiling
)(
    input  wire       clk,         // System clock
    input  wire       rst,         // Synchronous active-high reset
    input  wire       alu_active,  // 1 when ALU performed an operation
    output reg  [7:0] idle_count,  // Consecutive idle cycles (saturates)
    output reg  [7:0] activity_rate, // Active cycles / WINDOW_SIZE * 256
    output wire       is_idle      // 1 when current cycle is idle
);

    // -------------------------------------------------------------------------
    // Rolling activity window (shift register of 1-bit activity samples)
    // -------------------------------------------------------------------------
    reg [WINDOW_SIZE-1:0] act_window;  // Shift register, MSB = oldest

    // Popcount: count active cycles in the window (4-bit sufficient for 16)
    reg [4:0] pop_count;  // 0..16, fits in 5 bits
    integer i;

    // Compute popcount combinationally
    always @(*) begin
        pop_count = 5'd0;
        for (i = 0; i < WINDOW_SIZE; i = i + 1)
            pop_count = pop_count + {4'b0, act_window[i]};
    end

    // -------------------------------------------------------------------------
    // Update shift register, idle counter, and activity rate on each clock
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            act_window    <= {WINDOW_SIZE{1'b0}};
            idle_count    <= 8'd0;
            activity_rate <= 8'd0;
        end else begin
            // Shift window: shift in current activity at LSB, drop oldest (MSB)
            act_window <= {act_window[WINDOW_SIZE-2:0], alu_active};

            // Idle counter: increment on idle, reset on activity (saturating)
            if (alu_active) begin
                idle_count <= 8'd0;
            end else if (idle_count < IDLE_MAX) begin
                idle_count <= idle_count + 8'd1;
            end

            // Activity rate: (pop_count / WINDOW_SIZE) * 256
            // For WINDOW_SIZE=16: rate = pop_count << 4  (multiply by 16)
            // This scales 0..16 to 0..256 using only a shift
            if (pop_count == 5'd16)
                activity_rate <= 8'd255;
            else
                activity_rate <= {pop_count[3:0], 4'b0000};  // pop_count * 16
        end
    end

    // -------------------------------------------------------------------------
    // is_idle: purely combinational — no ALU activity this cycle
    // -------------------------------------------------------------------------
    assign is_idle = ~alu_active;

endmodule
