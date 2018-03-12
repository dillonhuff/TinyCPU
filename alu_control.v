`define STAGE_INSTR_FETCH 0
`define STAGE_MEMORY_READ 1
`define STAGE_REGISTER_UPDATE 2
`define STAGE_MEMORY_WRITE 3
`define STAGE_PC_UPDATE 4

module alu_control(input [31:0] PC_output,
                   input [2:0]   stage,
                   input [2:0] alu_operation,
                   
                   // Outputs sent to ALU
                   output [31:0] alu_in0,
                   output [31:0] alu_in1,
                   output [2:0]  alu_op_select
                   );

   assign alu_in0 = PC_output;
   assign alu_in1 = 32'h1;

   reg [2:0]                     alu_op_select_i;
   always @(*) begin
      if (stage == `STAGE_PC_UPDATE) begin
         alu_op_select_i = 3'h3;
      end else begin
         alu_op_select_i = alu_operation;
      end
   end

   assign alu_op_select = alu_op_select_i;
   

endmodule
