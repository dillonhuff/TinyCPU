`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module issue_register_control(
                              input `STAGE_WIDTH stage,

                              // Outputs sent to issue register
                              output issue_reg_en
                              );

   assign issue_reg_en = stage == `STAGE_FETCH;
   
endmodule
