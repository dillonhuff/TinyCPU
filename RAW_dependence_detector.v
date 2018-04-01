module RAW_dependence_detector(/* verilator lint_off UNUSED */
                               input [31:0] i0,
                               /* verilator lint_off UNUSED */
                               input [31:0] i1,

                               output       has_RAW_dependence);

   wire                                     i1_reads_0;
   wire                                     i1_reads_1;

   wire [4:0]                               i1_read_reg_0;
   wire [4:0]                               i1_read_reg_1;
   
   read_detector i1_reads(.instr(i1),
                          
                          .reads_0(i1_reads_0),
                          .reads_1(i1_reads_1),

                          .read_reg_0(i1_read_reg_0),
                          .read_reg_1(i1_read_reg_1));

   wire                                     i0_writes;
   wire [4:0]                               i0_write_reg;
   
   write_detector i0_write(.instr(i0),
                           
                           .writes(i0_writes),

                           .write_reg(i0_write_reg));
   

   assign has_RAW_dependence = i0_writes &&
                               (((i0_write_reg == i1_read_reg_0) && i1_reads_0) ||
                                ((i0_write_reg == i1_read_reg_1) && i1_reads_1));
   
   
endmodule
