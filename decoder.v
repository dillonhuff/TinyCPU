module decoder(
               /* verilator lint_off UNUSED */
               input [31:0]  instruction,


               output [4:0]  instruction_type,
               output [4:0]  load_imm_reg,
               output [31:0] load_imm_data,

               output [4:0]  load_mem_addr_reg,
               output [4:0]  load_mem_reg,

               output [4:0]  store_data_reg,
               output [4:0]  store_addr_reg,
               
               output [4:0]  alu_op_reg_0,
               output [4:0]  alu_op_reg_1,
               output [4:0]  alu_op_reg_res,
               output [2:0]  alu_operation
               );
   
   

   assign instruction_type = instruction[31:27];

   assign store_data_reg = instruction[26:22];
   assign store_addr_reg = instruction[21:17];
   

   assign load_imm_reg = instruction[10:6];
   assign load_imm_data = {{16{1'b0}}, instruction[26:11]};

   assign load_mem_addr_reg = instruction[26:22];
   assign load_mem_reg = instruction[21:17];
   
   assign alu_op_reg_0 = instruction[26:22];
   assign alu_op_reg_1 = instruction[21:17];
   assign alu_op_reg_res = instruction[16:12];
   assign alu_operation = instruction[11:9];
   

endmodule
