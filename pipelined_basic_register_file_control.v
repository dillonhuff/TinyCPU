`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module pipelined_basic_register_file_control(//input         `STAGE_WIDTH stage,
                                             input [4:0]   decode_instruction_type,
                                             /* verilator lint_off UNUSED */
                                             input [4:0]   write_back_instruction_type,

                                             input [4:0]   load_imm_reg,
                                             input [31:0]  load_imm_data,

                                             input [4:0]   load_mem_reg,
                                             input [4:0]   load_mem_addr_reg,
                                             input [31:0]  load_mem_data,
                             
                                             input [4:0]   alu_op_reg_0,
                                             input [4:0]   alu_op_reg_1,

                                             input [4:0]   alu_op_reg_res,
                                             input [31:0]  alu_result,
                                             input [4:0]   store_data_reg,
                                             input [4:0]   store_addr_reg,

                                             input [4:0]   jump_condition_reg,
                                             input [4:0]   jump_address_reg,
                             
                                             // Outputs are sent to main_memory
                                             output [4:0]  write_address,
                                             output [31:0] write_data,
                                             output        write_enable,
                                             output [4:0]  read_reg_0,
                                             output [4:0]  read_reg_1);

   // What are the semantics here?
   // the write back instruction decides the write_address, write_data, and
   // write_en

   wire                                    dec_is_alu_instr;
   assign dec_is_alu_instr = decode_instruction_type == `INSTR_ALU_OP;

   wire                                    dec_is_jump_instr;
   assign dec_is_jump_instr = decode_instruction_type == `INSTR_JUMP;
   
   wire                                    dec_is_load_imm_instr;
   assign dec_is_load_imm_instr = decode_instruction_type == `INSTR_LOAD_IMMEDIATE;

   wire                                    dec_is_load_instr;
   assign dec_is_load_instr = decode_instruction_type == `INSTR_LOAD;

   wire                                    dec_is_store_instr;
   assign dec_is_store_instr = decode_instruction_type == `INSTR_STORE;

   // Set write instr related flags   
   wire                                    wb_is_alu_instr;
   assign wb_is_alu_instr = write_back_instruction_type == `INSTR_ALU_OP;

   wire                                    wb_is_jump_instr;
   assign wb_is_jump_instr = write_back_instruction_type == `INSTR_JUMP;
   
   wire                                    wb_is_load_imm_instr;
   assign wb_is_load_imm_instr = write_back_instruction_type == `INSTR_LOAD_IMMEDIATE;

   wire                                    wb_is_load_instr;
   assign wb_is_load_instr = write_back_instruction_type == `INSTR_LOAD;

   wire                                    wb_is_store_instr;
   assign wb_is_store_instr = write_back_instruction_type == `INSTR_STORE;
   
   wire                                    wb_instr_updates_reg_file;
   assign wb_instr_updates_reg_file = wb_is_alu_instr || wb_is_load_imm_instr || wb_is_load_instr;
   
   reg [4:0]                               read_reg_0_i;
   reg [4:0]                               read_reg_1_i;

   // Set read values
   always @(*) begin
      if (dec_is_load_instr) begin
         assert(!dec_is_load_imm_instr);
         assert(!dec_is_alu_instr);

         read_reg_0_i = load_mem_addr_reg;

      end else if (dec_is_alu_instr) begin
         assert(!dec_is_load_imm_instr);
         assert(!dec_is_load_instr);

         read_reg_0_i = alu_op_reg_0;
         read_reg_1_i = alu_op_reg_1;
         
      end else if (dec_is_store_instr) begin
         read_reg_0_i = store_data_reg;
         read_reg_1_i = store_addr_reg;
         
      end else if (dec_is_jump_instr) begin
         read_reg_0_i = jump_condition_reg;
         read_reg_1_i = jump_address_reg;
      end
   end
   
   assign read_reg_0 = read_reg_0_i;
   assign read_reg_1 = read_reg_1_i;
   
   reg [4:0]                               write_address_i;
   reg [31:0]                               write_data_i;

   // Set write values   
   always @(*) begin
      if (wb_is_load_imm_instr) begin
         assert(!wb_is_load_instr);
         assert(!wb_is_alu_instr);

         write_address_i = load_imm_reg;
         write_data_i = load_imm_data;

      end else if (wb_is_load_instr) begin
         assert(!wb_is_load_imm_instr);
         assert(!wb_is_alu_instr);

         write_address_i = load_mem_reg;
         write_data_i = load_mem_data;

      end else if (wb_is_alu_instr) begin
         assert(!wb_is_load_imm_instr);
         assert(!wb_is_load_instr);

         write_address_i = alu_op_reg_res;
         write_data_i = alu_result;
      end
   end

   assign write_address = write_address_i;
   assign write_data = write_data_i;
   //assign write_enable = (stage == `STAGE_REGISTER_UPDATE) && wb_instr_updates_reg_file;
   assign write_enable = wb_instr_updates_reg_file;
   
   

endmodule
