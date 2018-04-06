module stage_write_back(
                        /* verilator lint_off UNUSED */
                        input [31:0] instruction_in,

                        output [4:0] write_back_load_mem_reg,
                        output [4:0] write_back_load_imm_reg,

                        output [4:0] wb_instruction_type,
                        output [4:0] alu_op_reg_res_wb,

                        output [31:0] write_back_load_imm_data);

   assign write_back_load_mem_reg = instruction_in[21:17];
   assign write_back_load_imm_reg = instruction_in[10:6];

   assign wb_instruction_type = instruction_in[31:27];

   assign alu_op_reg_res_wb = instruction_in[16:12];

   assign write_back_load_imm_data = {{16{1'b0}}, instruction_in[26:11]};
   
endmodule
