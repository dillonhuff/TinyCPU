module stall_detector(output [0:0] stall,
                      /* verilator lint_off UNUSED */
                      input [31:0] issue_reg_output,
                      input [31:0] decode_stage_instruction,
                      input [31:0] execute_stage_instruction,
                      input [31:0] memory_stage_instruction);


   wire any_instr_in_pipe =(32'h0 != decode_stage_instruction) ||
        (32'h0 != execute_stage_instruction) ||
        (32'h0 != memory_stage_instruction);

   assign stall = any_instr_in_pipe;

endmodule
