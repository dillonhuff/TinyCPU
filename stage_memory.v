module stage_memory(
                    //Inputs
                    input clk,
                    input [4:0]   current_instr_type,
                    input [31:0]  PC_value,

                    input [31:0]  memory_read_address,
                                  
                    input [31:0]  memory_write_data,
                    input [31:0]  memory_write_address,
      
                    // Outputs
                    output [31:0] read_data_0,
                    output [31:0] read_data_1

                    
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
   
endmodule
