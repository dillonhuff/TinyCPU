`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module cpu_pipelined_basic(input clk,
                           input rst
                                 
                                 // Debug info probes
`ifdef DEBUG_ON
                                 , output [31:0] PC_value
//                                 , output [31:0] mem_read_data
                                 , output [4:0] current_instruction_type_dbg
`endif // DEBUG_ON
                           );

   wire [31:0] main_mem_read_data_0;
   /* verilator lint_off UNUSED */
   wire [31:0] main_mem_read_data_1;

`ifdef DEBUG_ON
   assign PC_value = PC_output;
   //assign mem_read_data = main_mem_read_data_0;
   assign current_instruction_type_dbg = current_instruction_type;
`endif // DEBUG_ON

   // Stall detection logic
   wire stall;
   wire [4:0] current_instruction_type;
   
   stall_detector
     stall_detect(.stall(stall),
                  .issue_reg_output(current_instruction),
                  .decode_stage_instruction(decode_ireg_out),
                  .execute_stage_instruction(execute_ireg_out),
                  .memory_stage_instruction(memory_ireg_out)
                  );

   always @(posedge clk or negedge rst) begin

      $display("Instruction being issued  = %b", current_instruction);
      $display("decode_ireg_out           = %b", decode_ireg_out);
      $display("execute_ireg_out          = %b", execute_ireg_out);
      $display("memory_ireg_out           = %b", memory_ireg_out);
      $display("read_data_0               = %d", read_data_0);
      $display("read_data_1               = %d", read_data_1);
      $display("stall                     = %d", stall);
      $display("squash                    = %d", squash_issue);

   end

   // STAGE fetch   
   wire squash_issue;
   wire [31:0] PC_output;
   wire [31:0] current_instruction;

   wire [31:0] jump_condition;
   wire [31:0] jump_address;
   
   stage_fetch fetch_stage(.clk(clk),
                           .rst(rst),

                           .current_instruction_type(current_instruction_type),
                           .stall(stall),
                           // .jump_condition(read_data_0),
                           // .jump_address(read_data_1),

                           .jump_condition(jump_condition),
                           .jump_address(jump_address),

                           .main_mem_read_data_0(main_mem_read_data_0),

                           .squash_issue(squash_issue),

                           .PC_output(PC_output),
                           .current_instruction(current_instruction)
                           );

   // STAGE Decode
   wire [31:0]        read_data_0;
   wire [31:0]        read_data_1;

   wire [31:0] decode_ireg_out;

   stage_decode decode_stage(// Inputs
                             .clk(clk),
                             .rst(rst),

                             .alu_op_reg_res_wb(alu_op_reg_res_wb),

                             .stall(stall),
                             .squash(squash_issue),
                             .current_instruction(current_instruction),

                             .wb_instruction_type(wb_instruction_type),
                             .write_back_load_imm_reg(write_back_load_imm_reg),
                             .write_back_load_imm_data(write_back_load_imm_data),
                             .write_back_load_mem_reg(write_back_load_mem_reg),
                             .write_back_register_input(write_back_register_input),

                             // Outputs
                             .forwarded_jump_condition(jump_condition),
                             .forwarded_jump_address(jump_address),
                             
                             .read_data_0(read_data_0),
                             .read_data_1(read_data_1),
                             .decode_ireg_out(decode_ireg_out),
                             .current_instruction_type(current_instruction_type));
   
   // STAGE EXE
   wire [31:0] execute_ireg_out;
   wire [31:0] alu_result;

   wire [31:0] read_data_0_exe;
   wire [31:0] read_data_1_exe;
   
   stage_exe execute(.clk(clk),
                     .rst(rst),

                     .instruction_in(decode_ireg_out),
                     .instruction_out(execute_ireg_out),

                     .register_a_value(read_data_0),
                     .register_b_value(read_data_1),

                     .register_a_value_exe_out(read_data_0_exe),
                     .register_b_value_exe_out(read_data_1_exe),
                     
                     .alu_result(alu_result));
   
   // STAGE MEMORY
   wire [4:0]     ireg_out_instr_type;
   assign ireg_out_instr_type = execute_ireg_out[31:27];

   wire [31:0] write_back_register_input;
   wire [31:0] exe_result;
   wire [31:0] memory_ireg_out;
   stage_memory memory_stage(
                             .clk(clk),
                             .rst(rst),
                             
                             .current_instr_type(ireg_out_instr_type),
                             .PC_value(PC_output),

                             .alu_result(alu_result),
                             .memory_read_address(read_data_0_exe),

                             .memory_write_data(read_data_0_exe),
                             .memory_write_address(read_data_1_exe),

                             .read_data_0(main_mem_read_data_0),
                             .read_data_1(main_mem_read_data_1),

                             .write_back_register_input(write_back_register_input),
                             .exe_result(exe_result),

                             .execute_ireg_out(execute_ireg_out),
                             .memory_ireg_out(memory_ireg_out)

                             );

   // STAGE WRITE BACK
   wire [4:0] write_back_load_mem_reg;
   wire [4:0] write_back_load_imm_reg;
   wire [31:0] write_back_load_imm_data;
   wire [4:0]  wb_instruction_type;
   wire [4:0] alu_op_reg_res_wb;
   
   stage_write_back write_back(.instruction_in(memory_ireg_out),
                               .write_back_load_mem_reg(write_back_load_mem_reg),
                               .write_back_load_imm_reg(write_back_load_imm_reg),
                               .wb_instruction_type(wb_instruction_type),
                               .write_back_load_imm_data(write_back_load_imm_data),
                               .alu_op_reg_res_wb(alu_op_reg_res_wb));
   
endmodule
