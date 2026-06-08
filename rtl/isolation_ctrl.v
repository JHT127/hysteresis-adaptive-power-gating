// =============================================================================
// File        : isolation_ctrl.v
// Module      : isolation_ctrl
// Description : Applies isolation to ALU outputs when the power domain is in a
//               sleep state. Isolation clamping prevents X-propagation and
//               floating values from the power-gated ALU reaching the live
//               domain. When iso_en=1, result is clamped to ISO_VALUE (0).
//               This models the function of standard-cell ISO_AND / ISO_OR
//               cells placed at the power domain boundary in physical design.
//
//               In UPF flow, these cells are automatically inserted by DC;
//               this module provides the behavioral model for simulation.
// =============================================================================

module isolation_ctrl #(
    parameter DATA_WIDTH = 32,
    parameter ISO_VALUE  = 32'd0    // Clamp value when isolated (typically 0)
)(
    input  wire                  iso_en,    // 1 = domain is sleeping, clamp outputs
    input  wire [DATA_WIDTH-1:0] data_in,   // From power-gated ALU result
    input  wire                  valid_in,  // From power-gated ALU valid
    output wire [DATA_WIDTH-1:0] data_out,  // To live domain (clamped or pass)
    output wire                  valid_out  // To live domain (clamped or pass)
);

    // -------------------------------------------------------------------------
    // Combinational isolation: when iso_en is asserted, force outputs to safe
    // constant value (0 for AND-type isolation cell behavior).
    // -------------------------------------------------------------------------
    assign data_out  = iso_en ? ISO_VALUE  : data_in;
    assign valid_out = iso_en ? 1'b0       : valid_in;

endmodule
