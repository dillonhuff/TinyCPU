`define STAGE_INSTR_FETCH 0
`define STAGE_MEMORY_READ 1
`define STAGE_REGISTER_UPDATE 2
`define STAGE_MEMORY_WRITE 3
`define STAGE_PC_UPDATE 4

module register_file_control(input [2:0] stage,
                             output [4:0]  write_address,
                             output [31:0] write_data,
                             output        write_enable,
                             output [4:0] read_reg_0,
                             output [4:0] read_reg_1);

   assign write_enable = stage == `STAGE_REGISTER_UPDATE;
   assign write_address = 0;
   assign write_data = 0;

   assign read_reg_0 = 0;
   assign read_reg_1 = 0;

endmodule
