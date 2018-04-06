`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module branch_detector(
                       /* verilator lint_off UNUSED */
                       input [31:0] instr,
                       output       is_branch);

   assign is_branch = instr[31:27] == `INSTR_JUMP;

endmodule
