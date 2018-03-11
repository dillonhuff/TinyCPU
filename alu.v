module alu(input [31:0]  in0,
           input [31:0]  in1,
           input [4:0] op_select,
           output [31:0] out);
   
   assign out = in0 | in1;

endmodule
