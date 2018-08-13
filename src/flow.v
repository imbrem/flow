module flow(
  // Inputs
  input resetn,
  input clock,
  input user_clock,
  input clock_lock,
  output switch_clock,
  output[2:0] current_state,
  input[15:0] switches,

  // State as viewed from the FPGA top
  output[255:0] registers,
  output[15:0] zeroflag,
  output[15:0] signflag,
  output[15:0] overflow,
  output[15:0] errorbit,
  output[14:0] vga_color,
  output[7:0] vga_x,
  output[6:0] vga_y,
  output vga_plot,
  output vga_resetn,
  output[15:0] current_instruction,
  output program_counter_increment,
  output[15:0] alu_word,
  output[15:0] alu_a_altern,
  output[15:0] alu_b_altern,
  output alu_a_source,
  output alu_b_source,
  output[1:0] alu_load_src,
  output alu_store_to_mem,
  output alu_store_to_stk,
  output[15:0] alu_output
  );

  wire[3:0] alu_op;
  wire[3:0] alu_a_select;
  wire[3:0] alu_b_select;
  wire[3:0] alu_out_select;

  assign alu_word = {alu_op, alu_a_select, alu_b_select, alu_out_select};

  wire[3:0] vga_color_select;
  wire[3:0] vga_coord_select;

  datapath D(
    .resetn(resetn),
    .clock(clock),
    .program_counter_increment(program_counter_increment),
    .alu_op(alu_op),
    .alu_a_altern(alu_a_altern),
    .alu_b_altern(alu_b_altern),
    .alu_a_select(alu_a_select),
    .alu_b_select(alu_b_select),
    .alu_a_source(alu_a_source),
    .alu_b_source(alu_b_source),
    .alu_out_select(alu_out_select),
    .alu_load_src(alu_load_src),
    .alu_store_to_mem(alu_store_to_mem),
    .alu_store_to_stk(alu_store_to_stk),
    .alu_output(alu_output),
    .vga_color_select(vga_color_select),
    .vga_coord_select(vga_coord_select),
    .current_instruction(current_instruction),
    .signflag(signflag),
    .zeroflag(zeroflag),
    .overflow(overflow),
    .errorbit(errorbit),
    .vga_color(vga_color),
    .vga_x(vga_x),
    .vga_y(vga_y),
    .registers(registers));

  controlpath C(
    .resetn(resetn),
    .clock(clock),
    .user_clock(user_clock),
    .switch_clock(switch_clock),
    .clock_lock(clock_lock),
    .current_state(current_state),
    .current_instruction(current_instruction),
    .switches(switches),
    .signflag(signflag),
    .zeroflag(zeroflag),
    .overflow(overflow),
    .errorbit(errorbit),
    .program_counter_increment(program_counter_increment),
    .alu_op(alu_op),
    .alu_a_altern(alu_a_altern),
    .alu_b_altern(alu_b_altern),
    .alu_a_select(alu_a_select),
    .alu_b_select(alu_b_select),
    .alu_a_source(alu_a_source),
    .alu_b_source(alu_b_source),
    .alu_out_select(alu_out_select),
    .alu_load_src(alu_load_src),
    .alu_store_to_mem(alu_store_to_mem),
    .alu_store_to_stk(alu_store_to_stk),
    .vga_color_select(vga_color_select),
    .vga_coord_select(vga_coord_select),
    .vga_plot(vga_plot),
    .vga_resetn(vga_resetn));

endmodule
