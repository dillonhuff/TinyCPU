module counter(input clk,
               input                          rst,
               output [$clog2(N) - 1 : 0] out);
   
   parameter N = 2;

   reg [$clog2(N) - 1:0]                  data;
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
