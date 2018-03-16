module alu(input [31:0]  in0,
           input [31:0]  in1,
           input [4:0] op_select,
           output [31:0] out);

   wire [31:0]           out_or;
   wire [31:0]           out_and;
   wire [31:0]           out_xor;
   wire [31:0]           out_add;
   wire [31:0]           out_sub;
   wire [31:0]           out_mul;
   wire [31:0]           out_neq;
   wire [31:0]           out_logic_not;
   
   
   assign out_or = in0 | in1;
   assign out_and = in0 & in1;
   assign out_xor = in0 ^ in1;
   assign out_add = in0 + in1;
   assign out_sub = in0 - in1;
   assign out_mul = in0 * in1;
   assign out_neq = {{31{1'b0}}, in0 != in1};
   assign out_logic_not = {{31{1'b0}}, !(|in0)};

   reg [31:0]            out_r;
   always @(*) begin
      case (op_select)
        5'd0: out_r = out_or;
        5'd1: out_r = out_and;
        5'd2: out_r = out_xor;
        5'd3: out_r = out_add;
        5'd4: out_r = out_sub;
        5'd5: out_r = out_mul;
        5'd6: out_r = out_neq;
        5'd7: out_r = out_logic_not;
        
        default: out_r = 32'h0;
      endcase
   end

   assign out = out_r;
   
endmodule
