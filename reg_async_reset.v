module reg_async_reset(input [width - 1:0] D,
                       output [width - 1:0] Q,
                       input                clk,
                       input                rst);

   parameter width = 32;

   always @(posedge clk or negedge rst) begin
      if (!rst) begin
         Q <= 0;
      end else begin
         Q <= D;
      end
   end
   
endmodule
