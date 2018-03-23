module stall_detector(output [0:0] stall,
                      input [31:0] issue_reg_output,
                      input [31:0] decode_stage_instruction,
                      input [31:0] execute_stage_instruction,
                      input [31:0] memory_stage_instruction);

   wire                            issue_reg_holds_no_op;
   assign issue_reg_holds_no_op = issue_reg_output == 32'h0;

   wire issue_reg_instr_in_pipe;
   assign issue_reg_instr_in_pipe = (issue_reg_output == decode_stage_instruction) ||
                                    (issue_reg_output == execute_stage_instruction) ||
                                    (issue_reg_output == memory_stage_instruction);
   

   assign stall = !issue_reg_holds_no_op && issue_reg_instr_in_pipe;

endmodule
