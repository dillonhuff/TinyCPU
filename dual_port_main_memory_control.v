`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module dual_port_main_memory_control(

                                     //input         `STAGE_WIDTH stage,

                                     input [4:0]   current_instr_type,

                                     input [31:0]  PC_value,
                                     input [31:0]  memory_read_address,

                                     input [31:0]  memory_write_data,
                                     input [31:0]  memory_write_address,

                                     // Outputs to send to main memory
                                     output [31:0] read_address_0,
                                     output [31:0] read_address_1,

                                     output [31:0] write_address,
                                     output [31:0] write_data,
                                     output        write_enable);

   wire                                  current_instr_is_store;
   assign current_instr_is_store = current_instr_type == `INSTR_STORE;
   
   //assign write_enable = (stage == `STAGE_MEMORY) && current_instr_is_store;
   assign write_enable = current_instr_is_store;

   assign write_data = memory_write_data;
   assign write_address = memory_write_address;
   
   assign read_address_0 = PC_value;

   assign read_address_1 = memory_read_address;
   
endmodule
