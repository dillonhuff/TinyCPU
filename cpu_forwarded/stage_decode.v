module stage_decode(input clk,
                    input         rst,

                    input [4:0]   alu_op_reg_res_wb,

                    input         stall,
                    input         squash,

                    input [31:0]  current_instruction,

                    input [4:0]   wb_instruction_type,
                    input [4:0]   write_back_load_imm_reg,
                    input [31:0]  write_back_load_imm_data,
                    input [4:0]   write_back_load_mem_reg,
                    input [31:0]  write_back_register_input,

                    input [31:0] forwarded_alu_result,
                    
                    // Outputs

                    output [31:0] forwarded_jump_condition,
                    output [31:0] forwarded_jump_address,

                    output [31:0] read_data_0,
                    output [31:0] read_data_1,
                    output [31:0] decode_ireg_out,
                    output [4:0]  current_instruction_type
                    );

   /* verilator lint_off UNUSED */   
   wire [4:0] load_imm_reg;
   wire [31:0] load_imm_data;
   

   wire [4:0]  load_mem_reg;
   wire [4:0] load_mem_addr_reg;

   wire [4:0] alu_op_reg_0;
   wire [4:0] alu_op_reg_1;
   wire [4:0] alu_op_reg_res;
   wire [4:0] alu_operation;

   wire [4:0] store_data_reg;
   wire [4:0] store_addr_reg;

   wire [4:0] jump_condition_reg;
   wire [4:0] jump_address_reg;
   
   basic_pipeline_decoder
     instruction_decode(.instruction(current_instruction),

                        // Outputs
                        .instruction_type(current_instruction_type),
                        .load_imm_reg(load_imm_reg),
                        .load_imm_data(load_imm_data),

                        .load_mem_addr_reg(load_mem_addr_reg),
                        .load_mem_reg(load_mem_reg),

                        .store_data_reg(store_data_reg),
                        .store_addr_reg(store_addr_reg),

                        .alu_op_reg_0(alu_op_reg_0),
                        .alu_op_reg_1(alu_op_reg_1),
                        .alu_operation(alu_operation),

                        .jump_condition_reg(jump_condition_reg),
                        .jump_address_reg(jump_address_reg)
                        );

   // Register file
   wire [4:0] read_reg_0;
   wire [4:0] read_reg_1;
   wire [4:0] write_reg;

   wire [31:0] reg_file_write_data;

   wire        reg_file_write_en;

   pipelined_basic_register_file_control
     reg_file_ctrl(
                   // Control info
                   .decode_instruction_type(current_instruction_type),
                   .write_back_instruction_type(wb_instruction_type),

                   .load_imm_reg(write_back_load_imm_reg),
                   .load_imm_data(write_back_load_imm_data),

                   .load_mem_reg(write_back_load_mem_reg),
                   .load_mem_data(write_back_register_input),
                   .load_mem_addr_reg(load_mem_addr_reg),

                   // These should come from the write back register
                   .store_addr_reg(store_addr_reg),
                   .store_data_reg(store_data_reg),

                   .alu_op_reg_0(alu_op_reg_0),
                   .alu_op_reg_1(alu_op_reg_1),
                   .alu_op_reg_res(alu_op_reg_res_wb),
                   .alu_result(write_back_register_input),

                   // My guess is that jump condition registers need to be updated
                   .jump_condition_reg(jump_condition_reg),
                   .jump_address_reg(jump_address_reg),

                   // Inputs to the register file
                   .write_address(write_reg),
                   .write_data(reg_file_write_data),
                   .write_enable(reg_file_write_en),
                   .read_reg_0(read_reg_0),
                   .read_reg_1(read_reg_1));
   
   wire [31:0] reg_file_data_0;
   wire [31:0] reg_file_data_1;

   register_file reg_file(.read_address_0(read_reg_0),
                          .read_address_1(read_reg_1),

                          .read_data_0(reg_file_data_0),
                          .read_data_1(reg_file_data_1),

                          .write_address(write_reg),
                          .write_data(reg_file_write_data),
                          .write_enable(reg_file_write_en),
                          .clk(clk));
   
   // Pipeline registers for the operation fetch stage

   assign forwarded_jump_condition = reg_file_data_0;
   assign forwarded_jump_address = reg_file_data_1;
   

   wire [31:0]        operand_0_value;
   wire [31:0]        operand_1_value;

   // What needs to be passed in here?
   // I guess I need to add RAW dependence handling here to make the
   // system work?

   // Add feedback from exe stage instruction (the output of this stage)
   // and add a RAW dependence detector
   // Also augment the RAW dependence detector to output which instruction
   // argument has the dependence? Or the register # that has the dependence?

   // Its a good question actually, how do I detect which register(s) (if any?)
   // to set to the forwarded value?

   // Steps to calculation:
   // 1. Extract the arithmetic read registers (from decode instr)
   //    I already have this, these are the inputs to the register file
   // 2. Extract arithmetic write register (from exe instruction)
   // 3. Compare the written register id to the operand registers
   wire               operand_0_written_by_exe;
   wire               operand_1_written_by_exe;

   wire [31:0]        forwarded_exe_result;

   wire               exe_instr_writes;
   wire [4:0]         exe_instr_result_reg;
   
   write_detector exe_instr_write(.instr(decode_ireg_out),
                                  .writes(exe_instr_writes),
                                  .write_reg(exe_instr_result_reg));

   always @(posedge clk) begin

      $display("operand 0 written by exe = %d", operand_0_written_by_exe);
      $display("operand 1 written by exe = %d", operand_1_written_by_exe);
      $display("forwarded alu result     = %d", forwarded_alu_result);
      
   end

   assign operand_0_written_by_exe = exe_instr_writes && (exe_instr_result_reg == read_reg_0);
   assign operand_1_written_by_exe = exe_instr_writes && (exe_instr_result_reg == read_reg_1);
   
   assign operand_0_value = operand_0_written_by_exe ? forwarded_alu_result : reg_file_data_0;
   assign operand_1_value = operand_1_written_by_exe ? forwarded_alu_result : reg_file_data_1;
   
   reg_async_reset reg_file_data_0_r(.clk(clk),
                                     .rst(rst),
                                     .en(1'b1),
                                     .D(operand_0_value),
                                     .Q(read_data_0));

   reg_async_reset reg_file_data_1_r(.clk(clk),
                                     .rst(rst),
                                     .en(1'b1),
                                     .D(operand_1_value),
                                     .Q(read_data_1));

   wire [31:0] decode_ireg_input;
   // Next instruction is a NO-op
   assign decode_ireg_input = stall | squash ? 32'h0 : current_instruction;

   //wire [31:0] decode_ireg_out;
   wire [31:0] decode_ireg_instr;
   
   reg_async_reset end_decode_ireg(.clk(clk),
                                   .rst(rst),
                                   .en(1'b1),
                                   .D(decode_ireg_input),
                                   .Q(decode_ireg_instr));

   assign decode_ireg_out = squash ? 32'h0 : decode_ireg_instr;
   
endmodule
