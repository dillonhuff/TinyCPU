module stall_detector(output [0:0] stall,
                      /* verilator lint_off UNUSED */
                      input [31:0] issue_reg_output,
                      input [31:0] decode_stage_instruction,
                      input [31:0] execute_stage_instruction,
                      input [31:0] memory_stage_instruction);

   // New stall condition: Stall if:
   // 1. A branch has gotten past the issue stage. Q: Do I need to squash?
   // 2. An instruction past issue register writes a register that an
   //    instruction in the issue register reads

   wire                            decode_is_branch;
   branch_detector decode_b(.instr(decode_stage_instruction),
                            .is_branch(decode_is_branch));

   
   wire                            execute_is_branch;
   branch_detector execute_b(.instr(execute_stage_instruction),
                            .is_branch(execute_is_branch));

   wire                            memory_is_branch;
   branch_detector memory_b(.instr(memory_stage_instruction),
                            .is_branch(memory_is_branch));
   
   wire                            any_branch_past_issue;
   assign any_branch_past_issue = decode_is_branch ||
                                  execute_is_branch ||
                                  memory_is_branch;

   wire                            issued_i_reads_reg_0;
   wire                            issued_i_reads_reg_1;
   wire [4:0]                      issued_i_reg_0;
   wire [4:0]                      issued_i_reg_1;

   wire                            decode_RAW_dep;
   RAW_dependence_detector decode_detect(.i0(decode_stage_instruction),
                                         .i1(issue_reg_output),
                                         .has_RAW_dependence(decode_RAW_dep));

   wire                            execute_RAW_dep;
   RAW_dependence_detector execute_detect(.i0(execute_stage_instruction),
                                         .i1(issue_reg_output),
                                         .has_RAW_dependence(execute_RAW_dep));

   wire                            memory_RAW_dep;
   RAW_dependence_detector memory_detect(.i0(memory_stage_instruction),
                                         .i1(issue_reg_output),
                                         .has_RAW_dependence(memory_RAW_dep));
   
   assign stall = any_branch_past_issue ||
                  decode_RAW_dep ||
                  execute_RAW_dep ||
                  memory_RAW_dep;
   

   // wire any_instr_in_pipe = (32'h0 != decode_stage_instruction) ||
   //      (32'h0 != execute_stage_instruction) ||
   //      (32'h0 != memory_stage_instruction);

   // assign stall = any_instr_in_pipe;

endmodule
