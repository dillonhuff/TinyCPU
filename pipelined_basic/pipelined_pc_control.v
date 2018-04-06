`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

// I need pencil and paper to figure out the stall logic vs squash logic.

// Stall means: Introduce a bubble in the pipeline, the output of the issue
// register should just be a no-op while the pipeline is stalled

// Squash means: Cancel an instruction that is already in progress before it
// reaches the memory or write back stages. (Destroy contents of issue ireg,
// decode ireg or exe ireg) (Replace existing ireg with no-op)
module pipelined_pc_control(input [4:0] current_instruction_type,
                            input [0:0]   stall,
                            input [31:0]  alu_result,

                            input [31:0]  jump_condition,
                            input [31:0]  jump_address,

                            // Outputs to PC input
                            output [31:0] pc_input,
                            output        pc_en,
                            output        squash_issue
                  );
   

   assign pc_en = !stall;
   
   reg [31:0]                   pc_input_i;
   reg                          squash_issue_i;
   
   always @(*) begin
      squash_issue_i = 1'b0;
      
      // Should current instruction type be from the decode register?
      // A: Yes. The current instruction comes from the decode register
      //    and the register conditions come from the outputs of the register file,
      //    which is read in the decode stage (using inputs from the same register
      //    that provides current_instruction
      if (current_instruction_type == `INSTR_JUMP) begin
         if (jump_condition == 32'b1) begin
            pc_input_i = jump_address;
            squash_issue_i = 1'b1;
         end else begin
            pc_input_i = alu_result;
         end
      end else begin
         pc_input_i = alu_result;
      end
   end

   assign pc_input = pc_input_i;
   assign squash_issue = squash_issue_i;

   // Q: What is the appropriate squash policy?
   // A: When a jump condition is true (jump_condition == 1),
   //    squash the result of the issue register and the decode
   //    register?

endmodule
