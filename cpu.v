module cpu(input clk,
           input rst

           // Debug info probes
`ifdef DEBUG_ON
           , output [31:0] PC_value
           , output [31:0] mem_read_data
`endif // DEBUG_ON
           );

   wire [31:0] read_address;
   /* verilator lint_off UNUSED */
   wire [31:0] read_data;
   wire [31:0] write_address;
   wire [31:0] write_data;
   wire write_enable;

   wire [31:0] PC_input;
   wire [31:0] PC_output;

`ifdef DEBUG_ON
   assign PC_value = PC_output;
   assign mem_read_data = read_data;
`endif // DEBUG_ON
   
   reg_async_reset #(.width(32)) PC(.clk(clk),
                                    .rst(rst),
                                    .D(PC_input),
                                    .Q(PC_output));

   alu ALU(.in0(PC_output), .in1(32'h1), .op_select(3'h3), .out(PC_input));
   
   main_memory #(.depth(2048)) main_mem(.read_address(read_address),
                                        .read_data(read_data),
                                        .write_address(write_address),
                                        .write_data(write_data),
                                        .write_enable(write_enable),
                                        .clk(clk));

   // Dummy assigns
   assign read_address = PC_output;
   assign write_address = 32'h0;
   assign write_data = 32'h0;
   assign write_enable = 1'h0;
   
   
endmodule
