`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module counter #(parameter N=4) (input clk,
                                 input  rst,
                                 output `BUS_WIDTH(N) out);
   reg `BUS_WIDTH(N) data;

   always @(posedge clk or negedge rst) begin
      if (!rst) begin
         data <= 0;
      end else begin
         if (data == (N - 1)) begin
            data <= 0;
         end else begin
            data <= data + 1;
         end
      end
   end
   
   assign out = data;
   
endmodule
