`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module stage_pc_update(input clk,
                       input                             rst,
                       input [4:0]                       current_instruction_type,
                       input [$clog2(`NUM_STAGES) - 1:0] current_stage,
                       input [31:0]                      read_data_0,
                       input [31:0]                      read_data_1,
                       output [31:0]                     PC_output);

   wire [31:0] PC_input;
   //wire [31:0] PC_output;

   wire [31:0] PC_increment_result;
   assign PC_increment_result = PC_output + 32'h1;

   wire        PC_en;

   pc_control PC_ctrl(.current_instruction_type(current_instruction_type),
                      .alu_result(PC_increment_result),
                      .jump_condition(read_data_0),
                      .jump_address(read_data_1),
                      .stage(current_stage),

                      // To PC
                      .pc_input(PC_input),
                      .pc_en(PC_en));
   
   reg_async_reset #(.width(32)) PC(.clk(clk),
                                    .rst(rst),
                                    .en(PC_en),
                                    .D(PC_input),
                                    .Q(PC_output));

   

endmodule
