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
  output reg[255:0] registers);

  wire[15:0] selected_a;
  wire[15:0] selected_b;
  wire[15:0] selected_c;
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
  register_selector c_selector(alu_out_select, registers, selected_c);

  wire[255:0] register_uvs;
  wire[15:0] overflow_uv;
  wire[15:0] errorbit_uv;

  always @(negedge clock) begin
    registers[255:16] = register_uvs[255:16];
    registers[15:0] = register_uvs[15:0] + program_counter_increment;
    if(alu_load_src != 2'b00) begin
      overflow[alu_out_select] = alu_ofl;
      errorbit[alu_out_select] = alu_err;
    end
    overflow = overflow_uv;
    errorbit = errorbit_uv;
  end

  wire[15:0] at_memory;
  wire[15:0] at_stack;

  memory M(
      .clock(clock),
      .program_counter(registers[15:0]),
      .address(alu_output),
      .value(selected_c),
      .memory_store_enable(alu_store_to_mem),
      .stack_store_enable(alu_store_to_stk),
      .current_instruction(current_instruction),
      .at_memory(at_memory),
      .at_stack(at_stack));

  wire[15:0] address_value = alu_out_select[0] ? at_stack : at_memory;
  wire[15:0] update_value = alu_out_select[1] ? address_value : alu_output;

  register_updater R(
    .select(alu_out_select),
    .enable(alu_load_src != 2'b00),
    .value(update_value),
    .r(registers),
    .u(register_uvs));

  bit_updater overflow_updater(
    .select(alu_out_select),
    .enable(alu_load_src != 2'b00),
    .value(alu_ofl),
    .r(overflow),
    .u(overflow_uv));

  bit_updater errorbit_updater(
    .select(alu_out_select),
    .enable(alu_load_src != 2'b00),
    .value(alu_err),
    .r(errorbit),
    .u(errorbit_uv));



endmodule
