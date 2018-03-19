`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module pc_control(input [4:0] current_instruction_type,
                  input [31:0]  alu_result,

                  input [31:0]  jump_condition,
                  input [31:0]  jump_address,

                  input `STAGE_WIDTH stage,


                  // Outputs to PC input
                  output [31:0] pc_input,
                  output         pc_en
                  );
   

   assign pc_en = stage == `STAGE_FETCH;
   
   reg [31:0]                   pc_input_i;
   always @(*) begin
      if (current_instruction_type == `INSTR_JUMP) begin
         if (jump_condition == 32'b1) begin
            pc_input_i = jump_address;
         end else begin
            pc_input_i = alu_result;
         end
      end else begin
         pc_input_i = alu_result;
      end
   end

   assign pc_input = pc_input_i;

endmodule
