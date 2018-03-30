`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module cpu_pipelined_basic(input clk,
                           input rst
                                 
                                 // Debug info probes
`ifdef DEBUG_ON
                                 , output [31:0] PC_value
                                 , output [31:0] mem_read_data
                                 , output [4:0] current_instruction_type_dbg
`endif // DEBUG_ON
                           );

   wire [31:0] main_mem_read_data_0;
   /* verilator lint_off UNUSED */
   wire [31:0] main_mem_read_data_1;

`ifdef DEBUG_ON
   assign PC_value = PC_output;
   assign mem_read_data = main_mem_read_data_0;
   assign current_instruction_type_dbg = current_instruction_type;
`endif // DEBUG_ON

   // Stall logic
   wire stall;
   
   stall_detector
     stall_detect(.stall(stall),
                  .issue_reg_output(current_instruction),
                  .decode_stage_instruction(decode_ireg_out),
                  .execute_stage_instruction(execute_ireg_out),
                  .memory_stage_instruction(memory_ireg_out)
                  );
   

   wire squash_issue;
   wire [31:0] PC_output;
   stage_fetch fetch_stage(.clk(clk),
                           .rst(rst),

                           .current_instruction_type(current_instruction_type),
                           .stall(stall),
                           .jump_condition(read_data_0),
                           .jump_address(read_data_1),

                           .squash_issue(squash_issue),

                           .PC_output(PC_output)
                           );

   always @(posedge clk or negedge rst) begin

      $display("Instruction being issued  = %b", issue_register.Q);
      $display("decode_ireg_out           = %b", decode_ireg_out);
      $display("execute_ireg_out          = %b", execute_ireg_out);
      $display("memory_ireg_out           = %b", memory_ireg_out);
      $display("read_data_0               = %d", read_data_0);
      $display("read_data_1               = %d", read_data_1);
      $display("stall                     = %d", stall);

   end

   // Instruction decode
   wire             issue_reg_en;
   
   pipelined_basic_issue_register_control
     issue_reg_control(
                       .stall(stall),
                       .issue_reg_en(issue_reg_en));

   wire [31:0]      issue_register_input;
   assign issue_register_input = squash_issue ? 32'h0 : main_mem_read_data_0;
   reg_async_reset #(.width(32)) issue_register(.clk(clk),
                                                .rst(rst),
                                                .en(issue_reg_en),
                                                .D(issue_register_input),
                                                .Q(current_instruction));

   wire [31:0] current_instruction;
   wire [4:0] current_instruction_type;

   
   wire [4:0] load_imm_reg;
   wire [31:0] load_imm_data;
   

   wire [4:0]  load_mem_reg;
   wire [4:0] load_mem_addr_reg;

   wire [4:0]  alu_op_reg_0;
   wire [4:0] alu_op_reg_1;
   wire [4:0] alu_op_reg_res;
   wire [4:0] alu_op_reg_res_wb;
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
   

   wire [31:0]        read_data_0;
   wire [31:0]        read_data_1;
   
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
   reg_async_reset reg_file_data_0_r(.clk(clk),
                                     .rst(rst),
                                     .en(1'b1),
                                     .D(reg_file_data_0),
                                     .Q(read_data_0));

   reg_async_reset reg_file_data_1_r(.clk(clk),
                                     .rst(rst),
                                     .en(1'b1),
                                     .D(reg_file_data_1),
                                     .Q(read_data_1));

   wire [31:0] decode_ireg_input;
   // Next instruction is a NO-op
   assign decode_ireg_input = stall ? 32'h0 : current_instruction;

   wire [31:0] decode_ireg_out;
   reg_async_reset end_decode_ireg(.clk(clk),
                                   .rst(rst),
                                   .en(1'b1),
                                   .D(decode_ireg_input),
                                   .Q(decode_ireg_out));

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

   // Main memory
   // wire [31:0] main_mem_raddr_0;
   // wire [31:0] main_mem_raddr_1;

   // wire [31:0] main_mem_waddr;
   // wire [31:0] main_mem_wdata;
   // wire        main_mem_wen;

   wire [4:0]     ireg_out_instr_type;
   assign ireg_out_instr_type = execute_ireg_out[31:27];

   stage_memory memory_stage(
                             .current_instr_type(ireg_out_instr_type),
                             .PC_value(PC_output),

                             .memory_read_address(read_data_0_exe),

                             .memory_write_data(read_data_0_exe),
                             .memory_write_address(read_data_1_exe),

                             .read_data_0(main_mem_read_data_0),
                             .read_data_1(main_mem_read_data_1)

                             );
   
   // dual_port_main_memory_control main_mem_ctrl(
   //                                             // Inputs to select from
   //                                             .current_instr_type(ireg_out_instr_type),
   //                                             .PC_value(PC_output),

   //                                             .memory_read_address(read_data_0_exe),

   //                                             .memory_write_data(read_data_0_exe),
   //                                             .memory_write_address(read_data_1_exe),
      
   //                                             // Outputs to send to main_memory
   //                                             .read_address_0(main_mem_raddr_0),
   //                                             .read_address_1(main_mem_raddr_1),

   //                                             .write_address(main_mem_waddr),
   //                                             .write_data(main_mem_wdata),
   //                                             .write_enable(main_mem_wen)
   //                                             );
   
   // dual_port_main_memory #(.depth(2048)) main_mem(.read_address_0(main_mem_raddr_0),
   //                                                .read_address_1(main_mem_raddr_1),

   //                                                .read_data_0(main_mem_read_data_0),
   //                                                .read_data_1(main_mem_read_data_1),

   //                                                .write_address(main_mem_waddr),
   //                                                .write_data(main_mem_wdata),
   //                                                .write_enable(main_mem_wen),
   //                                                .clk(clk));
   
   wire [31:0] write_back_register_input;
   wire [4:0] write_back_load_mem_reg;
   wire [4:0] write_back_load_imm_reg;
   wire [31:0] write_back_load_imm_data;
   
   wire [31:0] exe_result;

   mem_result_control mem_res_control(.instr_type(ireg_out_instr_type),
                                      .read_data(main_mem_read_data_1),
                                      .alu_result(alu_result),
                                      .exe_result(exe_result));

   // Stores the result to be written back to memory
   reg_async_reset result_storage_MEM_reg(.clk(clk),
                                          .rst(rst),
                                          .en(1'b1),
                                          .D(exe_result),
                                          .Q(write_back_register_input));

   wire [31:0] memory_ireg_out;
   wire [4:0] wb_instruction_type;
   reg_async_reset end_memory_ireg(.clk(clk),
                                   .rst(rst),
                                   .en(1'b1),
                                   .D(execute_ireg_out),
                                   .Q(memory_ireg_out));

   stage_write_back write_back(.instruction_in(memory_ireg_out),
                               .write_back_load_mem_reg(write_back_load_mem_reg),
                               .write_back_load_imm_reg(write_back_load_imm_reg),
                               .wb_instruction_type(wb_instruction_type),
                               .write_back_load_imm_data(write_back_load_imm_data),
                               .alu_op_reg_res_wb(alu_op_reg_res_wb));
   
endmodule
