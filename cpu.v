module cpu(input clk);

   wire [31:0] read_address;
   /* verilator lint_off UNUSED */
   wire [31:0] read_data;
   wire [31:0] write_address;
   wire [31:0] write_data;
   wire write_enable;
   
   main_memory #(.depth(1)) main_mem(.read_address(read_address),
                                     .read_data(read_data),
                                     .write_address(write_address),
                                     .write_data(write_data),
                                     .write_enable(write_enable),
                                     .clk(clk));

   // Dummy assigns
   assign read_address = 32'h0;
   assign write_address = 32'h0;
   assign write_data = 32'h0;
   assign write_enable = 1'h0;
   
   
endmodule
