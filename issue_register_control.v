`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module issue_register_control(
                              input [$clog2(`NUM_STAGES) - 1:0] stage,

                              // Outputs sent to issue register
                              output issue_reg_en
                              );

   assign issue_reg_en = stage == `STAGE_INSTR_FETCH;
   
endmodule
