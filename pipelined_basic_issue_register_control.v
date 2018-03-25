`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module pipelined_basic_issue_register_control(
                                              input stall,
                                                    
                                              // Outputs sent to issue register
                                              output issue_reg_en
                                              );

   assign issue_reg_en = !stall;
   
endmodule
