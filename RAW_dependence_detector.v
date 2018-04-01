module RAW_dependence_detector(/* verilator lint_off UNUSED */
                               input [31:0] i0,
                               /* verilator lint_off UNUSED */
                               input [31:0] i1,

                               output       has_RAW_dependence);

   // read_detector i1_reads(.instr(i1));
   // write_detector i0_write(.instr(i0));

   assign has_RAW_dependence = 1'h0;
   
endmodule
