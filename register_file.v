module register_file(input [4:0] read_address,
                     output [31:0] read_data,
                     input [4:0]   write_address,
                     input [31:0]  write_data,
                     input write_enable,
                     input         clk);
   

   reg [31:0] registers[31:0];

   always @(posedge clk) begin
      if (write_enable) begin
         registers[write_address] <= write_data;
      end
   end

   // Reads are combinational
   assign read_data = registers[read_address];
   
   

endmodule
