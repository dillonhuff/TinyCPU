module stall_detector(output [0:0] stall,
                      input [31:0] issue_reg_output,
                      input [31:0] decode_stage_instruction,
                      input [31:0] execute_stage_instruction,
                      input [31:0] memory_stage_instruction);

   assign stall = 1'b0;

endmodule
