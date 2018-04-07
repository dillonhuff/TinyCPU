module stage_fetch(input clk,
                   input         rst,

                   input [31:0]  jump_condition,
                   input [31:0]  jump_address,

                   input [4:0]   current_instruction_type,

                   input         stall,

                   input [31:0] main_mem_read_data_0,

                   // Outputs
                   output [31:0] PC_output,
                   output        squash_issue,
                   output [31:0] current_instruction);

   wire        PC_en;
   wire [31:0] PC_input;

   wire [31:0] PC_increment_result;
   assign PC_increment_result = PC_output + 32'h1;

   pipelined_pc_control PC_ctrl(.current_instruction_type(current_instruction_type),
                                .stall(stall),
                                .alu_result(PC_increment_result),
                                .jump_condition(jump_condition),
                                .jump_address(jump_address),
                                
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

   wire             issue_reg_en;
   pipelined_basic_issue_register_control
     issue_reg_control(
                       .stall(stall),
                       .issue_reg_en(issue_reg_en));

   wire [31:0]      issue_register_input;
   assign issue_register_input = squash_issue ? 32'h0 : main_mem_read_data_0;

   wire [31:0] current_instruction_out;
   reg_async_reset #(.width(32)) issue_register(.clk(clk),
                                                .rst(rst),
                                                .en(issue_reg_en),
                                                .D(issue_register_input),
                                                .Q(current_instruction_out));

   //assign current_instruction = squash_issue ? 32'h0 : current_instruction_out;
   assign current_instruction = current_instruction_out;
   

endmodule
