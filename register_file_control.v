`define STAGE_INSTR_FETCH 0
`define STAGE_MEMORY_READ 1
`define STAGE_REGISTER_UPDATE 2
`define STAGE_MEMORY_WRITE 3
`define STAGE_PC_UPDATE 4

`define INSTR_NO_OP 0
`define INSTR_LOAD_IMMEDIATE 1
`define INSTR_LOAD 2
`define INSTR_ALU_OP 5

module register_file_control(input [2:0] stage,
                             input [4:0]   current_instruction_type,

                             input [4:0]   load_imm_reg,
                             input [31:0]  load_imm_data,

                             input [4:0]   load_mem_reg,
                             input [31:0]  load_mem_data,
                             
                             input [4:0]   alu_op_reg_0,
                             input [4:0]   alu_op_reg_1,

                             input [4:0]   alu_op_reg_res,
                             input [31:0] alu_result,
                             
                             output [4:0]  write_address,
                             output [31:0] write_data,
                             output        write_enable,
                             output [4:0]  read_reg_0,
                             output [4:0]  read_reg_1);

   wire                                    is_alu_instr;
   assign is_alu_instr = current_instruction_type == `INSTR_ALU_OP;

   wire                                    is_load_imm_instr;
   assign is_load_imm_instr = current_instruction_type == `INSTR_LOAD_IMMEDIATE;

   wire                                    is_load_instr;
   assign is_load_instr = current_instruction_type == `INSTR_LOAD;
   
   wire                                    current_instr_updates_reg_file;

   
   assign current_instr_updates_reg_file = is_alu_instr || is_load_imm_instr || is_load_instr;
        
   assign write_enable = (stage == `STAGE_REGISTER_UPDATE) && current_instr_updates_reg_file;

   reg [4:0]                               write_address_i;
   reg [4:0]                               read_reg_0_i;
   reg [4:0]                               read_reg_1_i;
   
   reg [31:0]                               write_data_i;
   
   always @(*) begin
      if (is_load_imm_instr) begin
         assert(!is_load_instr);
         assert(!is_alu_instr);

         write_address_i = load_imm_reg;
         write_data_i = load_imm_data;

      end else if (is_load_instr) begin
         assert(!is_load_imm_instr);
         assert(!is_alu_instr);

         write_address_i = load_mem_reg;
         write_data_i = load_mem_data;

      end else if (is_alu_instr) begin
         assert(!is_load_imm_instr);
         assert(!is_load_instr);

         write_address_i = alu_op_reg_res;
         read_reg_0_i = alu_op_reg_0;
         read_reg_1_i = alu_op_reg_1;
         write_data_i = alu_result;
      end
   end

   assign write_address = write_address_i;
   assign write_data = write_data_i;

   assign read_reg_0 = read_reg_0_i;
   assign read_reg_1 = read_reg_1_i;
   

endmodule
