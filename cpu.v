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

   wire [31:0] PC_input;
   wire [31:0] PC_output;

`ifdef DEBUG_ON
   assign PC_value = PC_output;
   assign mem_read_data = read_data;
   assign current_instruction_type_dbg = current_instruction_type;
`endif // DEBUG_ON

   wire [2:0]       current_stage;

   // Stage control
   counter #(.N(5)) stage_counter(.clk(clk),
                                  .rst(rst),
                                  .out(current_stage));

   wire             is_stage_instr_fetch;
   wire             is_stage_PC_update;

   assign is_stage_instr_fetch = current_stage == `STAGE_INSTR_FETCH;
   assign is_stage_PC_update = current_stage == `STAGE_PC_UPDATE;

   // Instruction decode
   reg_async_reset #(.width(32)) issue_register(.clk(clk),
                                                .rst(rst),
                                                .en(is_stage_instr_fetch),
                                                .D(read_data),
                                                .Q(current_instruction));

   always @(posedge clk) begin
      $display("Instruction being issued = %b", issue_register.Q);
      $display("Value of immediate = %b", load_imm_data);
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
   wire [2:0] alu_operation;

   wire [4:0] store_data_reg;
   wire [4:0] store_addr_reg;
   
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
                              .alu_operation(alu_operation));

   // Program counter   
   reg_async_reset #(.width(32)) PC(.clk(clk),
                                    .rst(rst),
                                    .en(is_stage_PC_update),
                                    .D(PC_input),
                                    .Q(PC_output));

   // Arithmetic logic unit
   wire [31:0] alu_result;

   wire [31:0] alu_in0;
   wire [31:0] alu_in1;
   wire [2:0]  alu_op_select;
   
   
   alu_control alu_ctrl(.PC_output(PC_output),
                        .stage(current_stage),
                        .alu_operation(alu_operation),

                        // Outputs sent to ALU
                        .alu_in0(alu_in0),
                        .alu_in1(alu_in1),
                        .alu_op_select(alu_op_select)
                        );
   
   //alu ALU(.in0(PC_output), .in1(32'h1), .op_select(3'h3), .out(alu_result));
   alu ALU(.in0(alu_in0),
           .in1(alu_in1),
           .op_select(alu_op_select),
           .out(alu_result));

   assign PC_input = alu_result;

   // Main memory control

   wire [31:0] main_mem_raddr;
   wire [31:0] main_mem_waddr;
   wire [31:0] main_mem_wdata;
   wire        main_mem_wen;

   main_memory_control main_mem_ctrl(
                                     // Inputs to select from
                                     .stage(current_stage),
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

   // Register file
   wire [4:0] read_reg_0;
   wire [4:0] read_reg_1;
   wire [4:0] write_reg;

   wire [31:0] reg_file_write_data;
   

   /* verilator lint_off UNOPTFLAT */
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
                                       .load_mem_data(read_data),
                                       .load_mem_addr_reg(load_mem_addr_reg),

                                       .store_addr_reg(store_addr_reg),
                                       .store_data_reg(store_data_reg),

                                       .alu_op_reg_0(alu_op_reg_0),
                                       .alu_op_reg_1(alu_op_reg_1),
                                       .alu_op_reg_res(alu_op_reg_res),
                                       .alu_result(alu_result),

                                       // Inputs to the register file
                                       .write_address(write_reg),
                                       .write_data(reg_file_write_data),
                                       .write_enable(reg_file_write_en),
                                       .read_reg_0(read_reg_0),
                                       .read_reg_1(read_reg_1));
   
   register_file reg_file(.read_address_0(read_reg_0),
                          .read_address_1(read_reg_1),
                          .read_data_0(read_data_0),
                          .read_data_1(read_data_1),
                          .write_address(write_reg),
                          .write_data(reg_file_write_data),
                          .write_enable(reg_file_write_en),
                          .clk(clk));
   
endmodule
