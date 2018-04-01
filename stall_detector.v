module stall_detector(output [0:0] stall,
                      /* verilator lint_off UNUSED */
                      input [31:0] issue_reg_output,
                      input [31:0] decode_stage_instruction,
                      input [31:0] execute_stage_instruction,
                      input [31:0] memory_stage_instruction);

   // New stall condition: Stall if:
   // 1. A branch has gotten past the issue stage. Q: Do I need to squash?
   // 2. 

   wire any_instr_in_pipe = (32'h0 != decode_stage_instruction) ||
        (32'h0 != execute_stage_instruction) ||
        (32'h0 != memory_stage_instruction);

   assign stall = any_instr_in_pipe;

endmodule
