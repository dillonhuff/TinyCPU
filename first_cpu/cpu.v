`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module cpu(input clk,
           input rst

           // Debug info probes
`ifdef DEBUG_ON
           , output [31:0] PC_value
           , output [31:0] mem_read_data
           , output [4:0] current_instruction_type_dbg
`endif // DEBUG_ON
           );

   /* verilator lint_off UNUSED */
   wire [31:0] read_data;

`ifdef DEBUG_ON
   assign PC_value = PC_output;
   assign mem_read_data = read_data;
   assign current_instruction_type_dbg = current_instruction_type;
`endif // DEBUG_ON

   wire `STAGE_WIDTH current_stage;

   // Stage counter
   counter #(.N(`NUM_STAGES)) stage_counter(.clk(clk),
                                            .rst(rst),
                                            .out(current_stage));

   wire             is_stage_instr_fetch;
   wire             is_stage_PC_update;

   // Program counter
   wire [31:0] PC_input;
   wire [31:0] PC_output;

   wire [31:0] PC_increment_result;
   assign PC_increment_result = PC_output + 32'h1;

   wire        PC_en;

   pc_control PC_ctrl(.current_instruction_type(current_instruction_type),
                      .alu_result(PC_increment_result),
                      .jump_condition(read_data_0),
                      .jump_address(read_data_1),
                      .stage(current_stage),

                      // To PC
                      .pc_input(PC_input),
                      .pc_en(PC_en));

   // The PC is the pipeline register for this stage   
   reg_async_reset #(.width(32)) PC(.clk(clk),
                                    .rst(rst),
                                    .en(PC_en),
                                    .D(PC_input),
                                    .Q(PC_output));

   // Instruction decode
   wire             issue_reg_en;
   
   issue_register_control issue_reg_control(.stage(current_stage),
                                            .issue_reg_en(issue_reg_en));
   
   reg_async_reset #(.width(32)) issue_register(.clk(clk),
                                                .rst(rst),
                                                .en(issue_reg_en),
                                                .D(read_data),
                                                .Q(current_instruction));

   always @(posedge clk or negedge rst) begin
      $display("Instruction being issued = %b", issue_register.Q);

      // $display("Value of immediate = %b", load_imm_data);
      // $display("Value of PC_input = %d", PC_input);
      // $display("Stage # %d", current_stage);
      // $display("ALU result = %d", alu_result);
      // $display("alu_in0    = %d", alu_in0);
      // $display("alu_in1    = %d", alu_in1);
      // $display("alu_op     = %d", alu_op_select);
   end

   wire [31:0] current_instruction;
   wire [4:0] current_instruction_type;

   
   wire [4:0] load_imm_reg;
   wire [31:0] load_imm_data;
   

   wire [4:0]  load_mem_reg;
   wire [4:0] load_mem_addr_reg;

   wire [4:0]  alu_op_reg_0;
   wire [4:0] alu_op_reg_1;
   wire [4:0] alu_op_reg_res;
   wire [4:0] alu_operation;

   wire [4:0] store_data_reg;
   wire [4:0] store_addr_reg;

   wire [4:0] jump_condition_reg;
   wire [4:0] jump_address_reg;
   
   decoder instruction_decode(.instruction(current_instruction),

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
                              .alu_op_reg_res(alu_op_reg_res),
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
   
   register_file_control reg_file_ctrl(
                                       // Control info
                                       .stage(current_stage),
                                       .current_instruction_type(current_instruction_type),

                                       .load_imm_reg(load_imm_reg),
                                       .load_imm_data(load_imm_data),

                                       .load_mem_reg(load_mem_reg),
                                       .load_mem_data(write_back_register_input), //read_data),
                                       .load_mem_addr_reg(load_mem_addr_reg),

                                       .store_addr_reg(store_addr_reg),
                                       .store_data_reg(store_data_reg),

                                       .alu_op_reg_0(alu_op_reg_0),
                                       .alu_op_reg_1(alu_op_reg_1),
                                       .alu_op_reg_res(alu_op_reg_res),
                                       //.alu_result(alu_result),
                                       .alu_result(write_back_register_input),

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
   
   // Arithmetic logic unit
   wire [31:0] alu_result_reg_input;
   wire [31:0] alu_result;

   wire [31:0] alu_in0;
   wire [31:0] alu_in1;
   wire [4:0]  alu_op_select;
   
   
   alu_control alu_ctrl(.alu_operation(alu_operation),

                        .reg_value_0(read_data_0),
                        .reg_value_1(read_data_1),

                        // Outputs sent to ALU
                        .alu_in0(alu_in0),
                        .alu_in1(alu_in1),
                        .alu_op_select(alu_op_select)
                        );
   
   alu ALU(.in0(alu_in0),
           .in1(alu_in1),
           .op_select(alu_op_select),
           .out(alu_result_reg_input));

   // Execution stage result pipeline register
   reg_async_reset alu_result_reg(.clk(clk),
                                  .rst(rst),
                                  .en(1'b1),
                                  .D(alu_result_reg_input),
                                  .Q(alu_result));

   // Main memory
   wire [31:0] main_mem_raddr;
   wire [31:0] main_mem_waddr;
   wire [31:0] main_mem_wdata;
   wire        main_mem_wen;

   main_memory_control main_mem_ctrl(
                                     // Inputs to select from
                                     .stage(current_stage),
                                     .current_instr_type(current_instruction_type),
                                     .PC_value(PC_output),

                                     .memory_read_address(read_data_0),

                                     .memory_write_data(read_data_0),
                                     .memory_write_address(read_data_1),
                                     
                                     // Outputs to send to main_memory
                                     .read_address(main_mem_raddr),
                                     .write_address(main_mem_waddr),
                                     .write_data(main_mem_wdata),
                                     .write_enable(main_mem_wen)
                                     );
   
   main_memory #(.depth(2048)) main_mem(.read_address(main_mem_raddr),
                                        .read_data(read_data),
                                        .write_address(main_mem_waddr),
                                        .write_data(main_mem_wdata),
                                        .write_enable(main_mem_wen),
                                        .clk(clk));

   wire [31:0] write_back_register_input;
   wire [31:0] exe_result;

   mem_result_control mem_res_control(.instr_type(current_instruction_type),
                                      .read_data(read_data),
                                      .alu_result(alu_result),
                                      .exe_result(exe_result));
   

   
   // Stores the result to be written back to memory   
   reg_async_reset result_storage_MEM_reg(.clk(clk),
                                          .rst(rst),
                                          .en(1'b1),
                                          .D(exe_result),
                                          .Q(write_back_register_input));
   
endmodule
