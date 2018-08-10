module datapath(
  input resetn,
  input clock,
  // Program counter increment
  input program_counter_increment,
  // ALU driver
  input[3:0] alu_op,
  input[15:0] alu_a_altern,
  input[15:0] alu_b_altern,
  input[3:0] alu_a_select,
  input[3:0] alu_b_select,
  input alu_a_source,
  input alu_b_source,
  // ALU output controller
  input[3:0] alu_out_select,
  input[1:0] alu_load_src,
  input alu_store_to_mem,
  input alu_store_to_stk,
  // ALU output
  output[15:0] alu_output,
  // VGA controller
  input[3:0] vga_color_select,
  input[3:0] vga_coord_select,
  // Current instruction
  output[15:0] current_instruction,
  // Flag registers
  output[15:0] signflag,
  output[15:0] zeroflag,
  output reg[15:0] overflow,
  output reg[15:0] errorbit,
  // VGA outputs
  output[14:0] vga_color,
  output[7:0] vga_x,
  output[6:0] vga_y,
  // Register view
  output reg[255:0] registers
  );

  wire[15:0] selected_a;
  wire[15:0] selected_b;
  wire alu_ofl;
  wire alu_err;

  ALU A(
    .alu_op(alu_op),
    .a(alu_a_source ? alu_a_altern : selected_a),
    .b(alu_b_source ? alu_b_altern : selected_b),
    .c(alu_output),
    .ofl(alu_ofl),
    .err(alu_err));

  register_selector a_selector(alu_a_select, registers, selected_a);
  register_selector b_selector(alu_b_select, registers, selected_b);

  wire[255:0] register_uvs;

  always @(negedge clock) begin
    registers[255:16] = register_uvs[255:16];
    registers[15:0] = register_uvs[15:0] + program_counter_increment;
  end

endmodule
