`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module alu_control(input [31:0] PC_output,
                   input [2:0]   stage,
                   input [2:0] alu_operation,
                   
                   // Outputs sent to ALU
                   output [31:0] alu_in0,
                   output [31:0] alu_in1,
                   output [2:0]  alu_op_select
                   );

   assign alu_in0 = PC_output;
   assign alu_in1 = 32'h1;

   reg [2:0]                     alu_op_select_i;
   always @(*) begin
      if (stage == `STAGE_PC_UPDATE) begin
         alu_op_select_i = `ALU_OP_ADD;
      end else begin
         alu_op_select_i = alu_operation;
      end
   end

   assign alu_op_select = alu_op_select_i;
   

endmodule
