`ifndef ARCH_DEFINES
`define ARCH_DEFINES
`include "arch_defines.v"
`endif // ARCH_DEFINES

module main_memory_control(

                           // Inputs
                           //input [2:0]   stage,
                           input `STAGE_WIDTH stage,

                           input [4:0]   current_instr_type,

                           input [31:0]  PC_value,
                           input [31:0]  memory_read_address,

                           input [31:0]  memory_write_data,
                           input [31:0]  memory_write_address,

                           // Outputs to send to main memory
                           output [31:0] read_address,
                           output [31:0] write_address,
                           output [31:0] write_data,
                           output        write_enable);

   wire                                  current_instr_is_store;
   assign current_instr_is_store = current_instr_type == `INSTR_STORE;
   
   assign write_enable = (stage == `STAGE_MEMORY) && current_instr_is_store;

   reg [31:0]                            read_address_i;

   assign write_data = memory_write_data;
   assign write_address = memory_write_address;
   
   always @(*) begin
      if (stage == `STAGE_FETCH) begin
         read_address_i = PC_value;
      end else begin
          read_address_i = memory_read_address;
      end
   end

   assign read_address = read_address_i;
   
   
endmodule
