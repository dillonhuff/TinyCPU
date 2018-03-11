module decoder(
               /* verilator lint_off UNUSED */
               input [31:0] instruction,
               output [4:0] instruction_type);

   assign instruction_type = instruction[31:27];

endmodule
