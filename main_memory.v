module main_memory(
                   /* verilator lint_off UNUSED */
                   input [31:0]  read_address,
                   output [31:0] read_data,

                   input [31:0]  write_address,
                   input [31:0]  write_data,

                   input         write_enable,
                   
                   input         clk);

   parameter depth = 2048;

   reg [31:0]                    mem[depth - 1 : 0];

   always @(posedge clk) begin

      if (write_enable) begin
         mem[write_address] <= write_data;
      end
      
   end

   assign read_data = mem[read_address];

endmodule
