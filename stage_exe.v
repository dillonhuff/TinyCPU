module stage_exe(input clk,
                 input        rst,
                 input [31:0] instruction_in,
                 input [31:0] register_a_value,
                 input [31:0] register_b_value,

                 output [31:0] instruction_out,
                 output [31:0] alu_result,

                 output [31:0] register_a_value_exe_out,
                 output [31:0] register_b_value_exe_out);

   wire [31:0] alu_result_reg_input;

   wire [31:0] alu_in0;
   wire [31:0] alu_in1;
   wire [4:0]  alu_op_select;

   wire [4:0]  ireg_alu_operation;

   assign ireg_alu_operation = instruction_in[11:7];

   alu_control alu_ctrl(.alu_operation(ireg_alu_operation),

                        .reg_value_0(register_a_value),
                        .reg_value_1(register_b_value),

                        // Outputs sent to ALU
                        .alu_in0(alu_in0),
                        .alu_in1(alu_in1),
                        .alu_op_select(alu_op_select)
                        );

   alu ALU(.in0(alu_in0),
           .in1(alu_in1),
           .op_select(alu_op_select),
           .out(alu_result_reg_input));

   // Execution stage result pipeline register
   reg_async_reset alu_result_reg(.clk(clk),
                                  .rst(rst),
                                  .en(1'b1),
                                  .D(alu_result_reg_input),
                                  .Q(alu_result));

   //wire [31:0] execute_ireg_out;
   reg_async_reset end_execute_ireg(.clk(clk),
                                    .rst(rst),
                                    .en(1'b1),
                                    .D(instruction_in),
                                    .Q(instruction_out));

   reg_async_reset reg_file_data_0_e(.clk(clk),
                                     .rst(rst),
                                     .en(1'b1),
                                     .D(register_a_value),
                                     .Q(register_a_value_exe_out));

   reg_async_reset reg_file_data_1_e(.clk(clk),
                                     .rst(rst),
                                     .en(1'b1),
                                     .D(register_b_value),
                                     .Q(register_b_value_exe_out));

endmodule
