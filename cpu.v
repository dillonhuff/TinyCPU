module cpu(input clk,
           input rst

           // Debug info probes
`ifdef DEBUG_ON
           , output [31:0] PC_value
`endif
           );

   wire [31:0] read_address;
   /* verilator lint_off UNUSED */
   wire [31:0] read_data;
   wire [31:0] write_address;
   wire [31:0] write_data;
   wire write_enable;

   wire [31:0] PC_input;
   wire [31:0] PC_output;

   // Dummy
   assign PC_value = PC_input;
   
   reg_async_reset #(.width(32)) PC(.clk(clk),
                                    .rst(rst),
                                    .D(PC_input),
                                    .Q(PC_output));

   alu ALU(.in0(PC_output), .in1(32'h1), .op_select(3'h3), .out(PC_input));
   
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
