module dual_port_main_memory(
                             /* verilator lint_off UNUSED */
                             input [31:0]  read_address_0,
                             input [31:0]  read_address_1,

                             output [31:0] read_data_0,
                             output [31:0] read_data_1,

                             input [31:0]  write_address,
                             input [31:0]  write_data,

                             input         write_enable,
                                           
                             input         clk);

   parameter depth = 2048;

   reg [31:0]                    mem[depth - 1 : 0];

   always @(posedge clk) begin

      $display("Reading from memory location %d", read_address);

      if (write_enable) begin
         $display("Writing %b to memory address %b", write_data, write_address);
         mem[write_address] <= write_data;
      end
      
   end

   assign read_data_0 = mem[read_address_0];
   assign read_data_1 = mem[read_address_1];

endmodule
