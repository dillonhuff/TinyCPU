module stage_decode(input clk,
                    input         rst,

                    // input [31:0]  reg_file_data_0,
                    // input [31:0]  reg_file_data_1,

                    input [4:0]   read_reg_0,
                    input [4:0]   read_reg_1,

                    input [4:0]   write_reg,
                    input [31:0]  reg_file_write_data,
                    input         reg_file_write_en,

                    input         stall,

                    input [31:0]  current_instruction,

                    // Outputs
                    output [31:0] read_data_0,
                    output [31:0] read_data_1,
                    output [31:0] decode_ireg_out
                    );

   wire [31:0] reg_file_data_0;
   wire [31:0] reg_file_data_1;

   register_file reg_file(.read_address_0(read_reg_0),
                          .read_address_1(read_reg_1),

                          .read_data_0(reg_file_data_0),
                          .read_data_1(reg_file_data_1),

                          .write_address(write_reg),
                          .write_data(reg_file_write_data),
                          .write_enable(reg_file_write_en),
                          .clk(clk));
   
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
