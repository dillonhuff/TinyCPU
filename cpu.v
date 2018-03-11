`define STAGE_INSTR_FETCH 0
`define STAGE_MEMORY_READ 1
`define STAGE_REGISTER_UPDATE 2
`define STAGE_MEMORY_WRITE 3
`define STAGE_PC_UPDATE 4

module cpu(input clk,
           input rst

           // Debug info probes
`ifdef DEBUG_ON
           , output [31:0] PC_value
           , output [31:0] mem_read_data
           , output [4:0] current_instruction_type_dbg
`endif // DEBUG_ON
           );

   wire [31:0] read_address;
   /* verilator lint_off UNUSED */
   wire [31:0] read_data;
   wire [31:0] write_address;
   wire [31:0] write_data;
   wire write_enable;

   wire [31:0] PC_input;
   wire [31:0] PC_output;

`ifdef DEBUG_ON
   assign PC_value = PC_output;
   assign mem_read_data = read_data;
   assign current_instruction_type_dbg = current_instruction_type;

`endif // DEBUG_ON

   wire [2:0]       current_stage;

   // Stage control
   counter #(.N(5)) stage_counter(.clk(clk),
                                  .rst(rst),
                                  .out(current_stage));

   wire             is_stage_instr_fetch;
   wire             is_stage_PC_update;

   assign is_stage_instr_fetch = current_stage == `STAGE_INSTR_FETCH;
   assign is_stage_PC_update = current_stage == `STAGE_PC_UPDATE;

   // Instruction decode
   reg_async_reset #(.width(32)) issue_register(.clk(clk),
                                                .rst(rst),
                                                .en(is_stage_instr_fetch),
                                                .D(read_data),
                                                .Q(current_instruction));

   wire [31:0] current_instruction;
   wire [4:0] current_instruction_type;
   decoder instruction_decode(.instruction(current_instruction),
                              .instruction_type(current_instruction_type));
   

   // Program counter   
   reg_async_reset #(.width(32)) PC(.clk(clk),
                                    .rst(rst),
                                    .en(is_stage_PC_update),
                                    .D(PC_input),
                                    .Q(PC_output));

   // Arithmetic logic unit
   alu ALU(.in0(PC_output), .in1(32'h1), .op_select(3'h3), .out(PC_input));

   // Main memory control
   main_memory #(.depth(2048)) main_mem(.read_address(read_address),
                                        .read_data(read_data),
                                        .write_address(write_address),
                                        .write_data(write_data),
                                        .write_enable(write_enable),
                                        .clk(clk));

   // Register file
   wire [4:0] read_reg_0;
   wire [4:0] read_reg_1;
   wire [4:0] write_reg;

   wire [31:0] reg_file_write_data;
   

   wire [31:0]        read_data_0;
   wire [31:0]        read_data_1;
   
   wire        reg_file_write_en;
   
   register_file_control reg_file_ctrl(.stage(current_stage),
                                       .write_address(write_reg),
                                       .write_data(reg_file_write_data),
                                       .write_enable(reg_file_write_en),
                                       .read_reg_0(read_reg_0),
                                       .read_reg_1(read_reg_1));
   
   register_file reg_file(.read_address_0(read_reg_0),
                          .read_address_1(read_reg_1),
                          .read_data_0(read_data_0),
                          .read_data_1(read_data_1),
                          .write_address(write_reg),
                          .write_data(write_data),
                          .write_enable(reg_file_write_en),
                          .clk(clk));
   
   // Dummy assigns
   assign read_address = PC_output;
   assign write_address = 32'h0;
   assign write_data = 32'h0;
   assign write_enable = 1'h0;
   
   
endmodule
