`define STAGE_INSTR_FETCH 0
`define STAGE_MEMORY_READ 1
`define STAGE_REGISTER_UPDATE 2
`define STAGE_MEMORY_WRITE 3
`define STAGE_PC_UPDATE 4


module main_memory_control(

                           // Inputs
                           input [2:0]   stage,

                           input [31:0]  PC_value,
                           input [31:0]  memory_read_address,

                           input [31:0]  memory_write_data,
                           input [31:0]  memory_write_address,

                           // Outputs to send to main memory
                           output [31:0] read_address,
                           output [31:0] write_address,
                           output [31:0] write_data,
                           output        write_enable);

   assign write_enable = (stage == `STAGE_MEMORY_WRITE);

   reg [31:0]                            read_address_i;

   assign write_data = memory_write_data;
   assign write_address = memory_write_address;
   
   always @(*) begin
      if (stage == `STAGE_INSTR_FETCH) begin
         read_address_i = PC_value;
      end else if (stage == `STAGE_MEMORY_READ) begin
         read_address_i = memory_read_address;
      end
   end

   assign read_address = read_address_i;
   
   
endmodule
