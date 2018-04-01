`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module write_detector(input [31:0] instr,

                      output       writes,
                      output [4:0] write_reg);

   wire [4:0]                      instr_type;
   assign instr_type = instr[31:27];
   
   assign writes = (instr_type == `INSTR_ALU_OP) ||
                   (instr_type == `INSTR_LOAD) ||
                   (instr_type == `INSTR_LOAD_IMMEDIATE);

   reg [4:0]                       write_reg_i;
   always @(*) begin
      if (instr_type == `INSTR_ALU_OP) begin
         write_reg_i = instr[16:12];
      end else if (instr_type == `INSTR_LOAD) begin
         write_reg_i = instr[21:17];
      end else if (instr_type == `INSTR_LOAD_IMMEDIATE) begin
         write_reg_i = instr[10:6];
      end
   end

   assign write_reg = write_reg_i;
   
   
endmodule
