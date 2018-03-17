module cpu_pipelined_basic(input clk,
                           input rst);

   // Main memory
   wire [31:0]                   main_mem_read_data;
   wire [31:0]                   main_mem_read_addr;
   wire [31:0]                   main_mem_write_addr;
   wire [31:0]                   main_mem_write_data;
   wire                          main_mem_write_enable;

   main_memory mem(.read_data(main_mem_read_data),
                   .read_addr(main_mem_read_addr),
                   .write_data(main_mem_write_data),
                   .write_address(main_mem_write_addr),
                   .write_enable(main_mem_write_enable));

   // Program counter
   reg_async_reset PC(.clk(clk),
                      .rst(rst));

   // Issue register
   reg_async_reset issue_reg(.clk(clk),
                             .rst(rst));

   // Decode phase outputs
   wire [31:0]                   reg_a_out;
   wire [31:0]                   reg_b_out;
   
   reg_async_reset reg_a(.clk(clk),
                         .rst(rst),
                         .Q(reg_a_out));

   reg_async_reset reg_b(.clk(clk),
                         .rst(rst),
                         .Q(reg_b_out));

   reg_async_reset instr_reg_decode(.clk(clk),
                                    .rst(rst));

   // Execute phase outputs
   wire [31:0]                   alu_out;
   alu ALU(.in0(reg_a_out),
           .in1(reg_b_out),
           .op_select(),
           .out(alu_out));
   
   reg_async_reset exe_res(.clk(clk),
                           .rst(rst),
                           .D(alu_out));

   reg_async_reset instr_reg_exe(.clk(clk),
                                 .rst(rst));

   // write back result
   reg_async_reset wb_value(.clk(clk),
                            .rst(rst));

   reg_async_reset instr_reg_wb(.clk(clk),
                                .rst(rst));
   
   
endmodule
