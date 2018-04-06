`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module mem_result_control(input [4:0] instr_type,
                          input [31:0]  read_data,
                          input [31:0]  alu_result,

                          // Output to the result_storage_MEM_reg
                          output [31:0] exe_result
                          );
   

   reg [31:0]                           exe_result_i;
   always @(*) begin
      if (instr_type == `INSTR_LOAD) begin
         exe_result_i = read_data;
      end else begin
         exe_result_i = alu_result;
      end
   end

   assign exe_result = exe_result_i;

endmodule
