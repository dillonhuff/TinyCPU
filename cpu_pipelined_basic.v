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

   wire `STAGE_WIDTH current_stage;

   // Stage counter
   counter #(.N(`NUM_STAGES)) stage_counter(.clk(clk),
                                            .rst(rst),
                                            .out(current_stage));
   

   // Stall logic
   wire stall;
   
   stall_detector
     stall_detect(.stall(stall),
                  .issue_reg_output(current_instruction),
                  .decode_stage_instruction(decode_ireg_out),
                  .execute_stage_instruction(execute_ireg_out),
                  .memory_stage_instruction(memory_ireg_out)
                  );
   
   
   // Stage logic
   // Program counter
   wire [31:0] PC_input;
   wire [31:0] PC_output;

   wire [31:0] PC_increment_result;
   assign PC_increment_result = PC_output + 32'h1;

   wire        PC_en;

   // STAGE FETCH
   pipelined_pc_control PC_ctrl(.current_instruction_type(current_instruction_type),
                                .stall(stall),
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

   // STAGE DECODE

   // Instruction decode
   wire             issue_reg_en;
   
   issue_register_control issue_reg_control(.stage(current_stage),
                                            .issue_reg_en(issue_reg_en));
   
   reg_async_reset #(.width(32)) issue_register(.clk(clk),
                                                .rst(rst),
                                                .en(issue_reg_en),
                                                .D(main_mem_read_data_0),
                                                .Q(current_instruction));

   always @(posedge clk or negedge rst) begin
      $display("Instruction being issued = %b", issue_register.Q);
      $display("stall                    = %d", stall);

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

                   .load_imm_reg(load_imm_reg),
                   .load_imm_data(load_imm_data),

                   .load_mem_reg(load_mem_reg),
                   .load_mem_data(write_back_register_input),
                   .load_mem_addr_reg(load_mem_addr_reg),

                   .store_addr_reg(store_addr_reg),
                   .store_data_reg(store_data_reg),

                   .alu_op_reg_0(alu_op_reg_0),
                   .alu_op_reg_1(alu_op_reg_1),
                   .alu_op_reg_res(alu_op_reg_res_wb),
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

   wire [31:0] decode_ireg_input;
   // Next instruction is a NO-op
   assign decode_ireg_input = stall ? 32'h0 : current_instruction;

   wire [31:0] decode_ireg_out;
   reg_async_reset end_decode_ireg(.clk(clk),
                                   .rst(rst),
                                   .en(1'b1),
                                   .D(decode_ireg_input),
                                   .Q(decode_ireg_out));

   wire [4:0]  ireg_alu_operation;
   assign ireg_alu_operation = decode_ireg_out[11:7];
   

   // STAGE EXE   
   // Arithmetic logic unit
   wire [31:0] alu_result_reg_input;
   wire [31:0] alu_result;

   wire [31:0] alu_in0;
   wire [31:0] alu_in1;
   wire [4:0]  alu_op_select;
   
   
   alu_control alu_ctrl(.alu_operation(ireg_alu_operation), //.alu_operation(alu_operation),

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

   wire [31:0] execute_ireg_out;
   reg_async_reset end_execute_ireg(.clk(clk),
                                    .rst(rst),
                                    .en(1'b1),
                                    .D(decode_ireg_out),
                                    .Q(execute_ireg_out));
   
   // STAGE MEMORY

   // Main memory
   wire [31:0] main_mem_raddr_0;
   wire [31:0] main_mem_raddr_1;

   wire [31:0] main_mem_waddr;
   wire [31:0] main_mem_wdata;
   wire        main_mem_wen;

   wire [4:0]     ireg_out_instr_type;
   assign ireg_out_instr_type = execute_ireg_out[31:27];

   dual_port_main_memory_control main_mem_ctrl(
                                               // Inputs to select from
                                               .stage(current_stage),
                                               .current_instr_type(ireg_out_instr_type),
                                               .PC_value(PC_output),

                                               .memory_read_address(read_data_0),

                                               .memory_write_data(read_data_0),
                                               .memory_write_address(read_data_1),
      
                                               // Outputs to send to main_memory
                                               .read_address_0(main_mem_raddr_0),
                                               .read_address_1(main_mem_raddr_1),

                                               .write_address(main_mem_waddr),
                                               .write_data(main_mem_wdata),
                                               .write_enable(main_mem_wen)
                                               );
   
   dual_port_main_memory #(.depth(2048)) main_mem(.read_address_0(main_mem_raddr_0),
                                                  .read_address_1(main_mem_raddr_1),

                                                  .read_data_0(main_mem_read_data_0),
                                                  .read_data_1(main_mem_read_data_1),

                                                  .write_address(main_mem_waddr),
                                                  .write_data(main_mem_wdata),
                                                  .write_enable(main_mem_wen),
                                                  .clk(clk));
   
   wire [31:0] write_back_register_input;
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

   assign wb_instruction_type = memory_ireg_out[31:27];
   assign alu_op_reg_res_wb = memory_ireg_out[16:12];
   
   // STAGE Write back (no logic)

   // Maybe good stall logic to emulate single cycle would be:
   // stall if the issue register is not a no-op and one of the instruction
   // registers after issue register is equal to the issue register value

   // DONE
   // 1. Change to dual port read memory   
   // 2. Insert instruction registers for execute, memory, write back phases
   //    or put another way: end of decode, end of execute and end of memory
   // 3. Move control logic from instructions to the stage-wise instruction
   //    registers   
   // 4. Add stall detector

   // Now maybe I need to add the stall detector and build the logic for the
   // stall detection system before attaching instruction register specific
   // values to the rest of the CPU control?

   // My worry is that now the CPU is effectively a CPU that stalls when
   // an instruction is issued util that instruction leaves the pipeline and
   // then re-starts. BUT the current CPU issues the current instruction in
   // the issue register as the bubble instruction instead of a NO-OP.

   // Now: Stall logic looks ok, but I get a stall 2 cycles after

   // I still dont have great intuition about how cycles happen and when
   // things change over time

   // before clock 0 : issue reg is 0, stall is 0, PC = 0
   // after clock 0  : issue reg is MEM[0], stall is 0, PC = 1
   // after clock 1  : issue reg is MEM[1], stall is 1, PC = ??

   // TODO:

   // 5. Replace stage checking logic with stall logic
   // 6. Remove stage counter

   
endmodule
