module stage_memory(
                    //Inputs
                    input         clk,
                    input         rst,
                    input [4:0]   current_instr_type,
                    input [31:0]  PC_value,

                    input [31:0]  memory_read_address,
                                  
                    input [31:0]  memory_write_data,
                    input [31:0]  memory_write_address,

                    input [31:0] alu_result,

                    input [31:0] execute_ireg_out,
      
                    // Outputs
                    output [31:0] read_data_0,
                    output [31:0] read_data_1,

                    output [31:0] write_back_register_input,
                    output [31:0] exe_result,


                    output [31:0] memory_ireg_out
                    );

   wire [31:0] main_mem_raddr_0;
   wire [31:0] main_mem_raddr_1;

   wire [31:0] main_mem_waddr;
   wire [31:0] main_mem_wdata;
   wire        main_mem_wen;
   
   dual_port_main_memory_control main_mem_ctrl(
                                               // Inputs to select from
                                               .current_instr_type(current_instr_type),
                                               .PC_value(PC_value),

                                               .memory_read_address(memory_read_address),

                                               .memory_write_data(memory_write_data),
                                               .memory_write_address(memory_write_address),
      
                                               // Outputs to send to main_memory
                                               .read_address_0(main_mem_raddr_0),
                                               .read_address_1(main_mem_raddr_1),

                                               .write_address(main_mem_waddr),
                                               .write_data(main_mem_wdata),
                                               .write_enable(main_mem_wen)
                                               );
   
   dual_port_main_memory #(.depth(2048)) main_mem(.read_address_0(main_mem_raddr_0),
                                                  .read_address_1(main_mem_raddr_1),

                                                  .read_data_0(read_data_0),
                                                  .read_data_1(read_data_1),

                                                  .write_address(main_mem_waddr),
                                                  .write_data(main_mem_wdata),
                                                  .write_enable(main_mem_wen),
                                                  .clk(clk));

   wire [31:0] write_back_register_input;
   wire [31:0] exe_result;

   mem_result_control mem_res_control(.instr_type(current_instr_type),
                                      .read_data(read_data_1),
                                      .alu_result(alu_result),
                                      .exe_result(exe_result));

   // Stores the result to be written back to memory
   reg_async_reset result_storage_MEM_reg(.clk(clk),
                                          .rst(rst),
                                          .en(1'b1),
                                          .D(exe_result),
                                          .Q(write_back_register_input));

   //wire [31:0] memory_ireg_out;
   
   reg_async_reset end_memory_ireg(.clk(clk),
                                   .rst(rst),
                                   .en(1'b1),
                                   .D(execute_ireg_out),
                                   .Q(memory_ireg_out));
   
endmodule
