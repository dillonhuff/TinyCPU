module read_detector(
                     /* verilator lint_off UNUSED */
                     input [31:0] instr,
                     
                     output       reads_0,
                     output       reads_1,

                     output [4:0] read_reg_0,
                     output [4:0] read_reg_1);

   wire [4:0]                     instr_type;
   assign instr_type = instr[31:27];

   reg                            reads_0_i;
   reg                            reads_1_i;
   reg [4:0]                      read_reg_0_i;
   reg [4:0]                      read_reg_1_i;

   always @(*) begin
      if (instr_type == `INSTR_LOAD) begin

         reads_0_i = 1;
         read_reg_0_i = instr[26:22];
         
      end else if (instr_type == `INSTR_STORE) begin

         reads_0_i = 1;
         read_reg_0_i = instr[26:22];

         reads_1_i = 1;
         read_reg_1_i = instr[21:17];
         
      end else if (instr_type == `INSTR_ALU_OP) begin

         reads_0_i = 1;
         read_reg_0_i = instr[26:22];

         // TODO: Check if operation is unary
         reads_1_i = 1;
         read_reg_1_i = instr[21:17];
         
      end else if (instr_type == `INSTR_JUMP) begin

         reads_0_i = 1;
         read_reg_0_i = instr[26:22];

         reads_1_i = 1;
         read_reg_1_i = instr[21:17];
         
      end else begin
         reads_0_i = 0;
         reads_1_i = 0;
      end
        
   end

   assign read_reg_0 = read_reg_0_i;
   assign read_reg_1 = read_reg_1_i;

   assign reads_0 = reads_0_i;
   assign reads_1 = reads_1_i;
   
endmodule
