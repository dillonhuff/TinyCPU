`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

// NOTE: Need to update for the case where multiplier works
module alu_control(
                   input [4:0]   alu_operation,

                   input [31:0]  reg_value_0,
                   input [31:0]  reg_value_1,

                   // Outputs sent to ALU
                   output [31:0] alu_in0,
                   output [31:0] alu_in1,
                   output [4:0]  alu_op_select
                   );

   reg [31:0]                    alu_in0_i;
   reg [31:0]                    alu_in1_i;

   reg [4:0]                     alu_op_select_i;
   always @(*) begin
      alu_op_select_i = alu_operation;
      alu_in0_i = reg_value_0;
      alu_in1_i = reg_value_1;
   end

   assign alu_op_select = alu_op_select_i;
   assign alu_in0 = alu_in0_i;
   assign alu_in1 = alu_in1_i;

endmodule
