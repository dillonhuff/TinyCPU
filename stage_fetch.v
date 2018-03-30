module stage_fetch(input clk,
                   input        rst,

                   input [31:0] alu_result,
                   input [31:0] jump_condition,
                   input [31:0] jump_address,

                   output       squash_issue);

   wire        PC_en;
   
   pipelined_pc_control PC_ctrl(.current_instruction_type(current_instruction_type),
                                .stall(stall),
                                .alu_result(PC_increment_result),
                                .jump_condition(read_data_0),
                                .jump_address(read_data_1),
                                
                                // To PC
                                .squash_issue(squash_issue),
                                .pc_input(PC_input),
                                .pc_en(PC_en));

   // The PC is the pipeline register for this stage   
   reg_async_reset #(.width(32)) PC(.clk(clk),
                                    .rst(rst),
                                    .en(PC_en),
                                    .D(PC_input),
                                    .Q(PC_output));
   

endmodule
