module controlpath(
  input resetn,
  // Timing controls
  input clock,
  input user_clock,
  input switch_clock,
  input clock_lock,
  // Current instruction
  input[15:0] current_instruction,
  // Switch register
  input[15:0] switches,
  // Flag registers
  input[15:0] signflag,
  input[15:0] zeroflag,
  input[15:0] overflow,
  input[15:0] errorbit,
  // Program counter increment (yes/no)
  output program_counter_increment,
  // ALU driver
  output[3:0] alu_op,
  output[15:0] alu_a_altern, // Alternative input A
  output[15:0] alu_b_altern, // Alternative input B
  output[3:0] alu_a_select, // Register for input A
  output[3:0] alu_b_select, // Register for input B
  output alu_a_source, // Source for input A (reg/alt)
  output alu_b_source, // Source for input B (reg/alt)
  // ALU output controller
  output[3:0] alu_out_select, // Destination register
  output[1:0] alu_load_src, // Load source (self, alu, mem, stk)
  output alu_store_to_mem, // Store reg[C] to mem[ALU]
  output alu_store_to_stk, // Store reg[C] to stk[ALU]
  // VGA driver
  output[3:0] vga_color_select,
  output[3:0] vga_coord_select,
  output vga_plot,
  output vga_resetn);

endmodule
