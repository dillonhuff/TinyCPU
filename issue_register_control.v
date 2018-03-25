`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module issue_register_control(
                              /* verilator lint_off UNUSED */
                              input  `STAGE_WIDTH stage,
                              input  stall,

                              // Outputs sent to issue register
                              output issue_reg_en
                              );

   //assign issue_reg_en = stage == `STAGE_FETCH;
   assign issue_reg_en = 1'b1;
   
endmodule
