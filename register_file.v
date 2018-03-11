module register_file(input [4:0]   read_address_0,
                     output [31:0] read_data_0,
                     input [4:0]   read_address_1,
                     output [31:0] read_data_1, 
                     input [4:0]   write_address,
                     input [31:0]  write_data,
                     input         write_enable,
                     input         clk);
   

   reg [31:0] registers[31:0];

   always @(posedge clk) begin
      if (write_enable) begin
         registers[write_address] <= write_data;
      end
   end

   // Reads are combinational
   assign read_data_0 = registers[read_address_0];
   assign read_data_1 = registers[read_address_1];

endmodule