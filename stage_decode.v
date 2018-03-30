module stage_decode(input clk,
                    input         rst,

                    input [31:0]  reg_file_data_0,
                    input [31:0]  reg_file_data_1,

                    input         stall,

                    input [31:0] current_instruction,

                    // Outputs
                    output [31:0] read_data_0,
                    output [31:0] read_data_1,
                    output [31:0] decode_ireg_out
                    );

   // Pipeline registers for the operation fetch stage
   reg_async_reset reg_file_data_0_r(.clk(clk),
                                     .rst(rst),
                                     .en(1'b1),
                                     .D(reg_file_data_0),
                                     .Q(read_data_0));

   reg_async_reset reg_file_data_1_r(.clk(clk),
                                     .rst(rst),
                                     .en(1'b1),
                                     .D(reg_file_data_1),
                                     .Q(read_data_1));

   wire [31:0] decode_ireg_input;
   // Next instruction is a NO-op
   assign decode_ireg_input = stall ? 32'h0 : current_instruction;

   wire [31:0] decode_ireg_out;
   reg_async_reset end_decode_ireg(.clk(clk),
                                   .rst(rst),
                                   .en(1'b1),
                                   .D(decode_ireg_input),
                                   .Q(decode_ireg_out));

   
endmodule
