module datapath_tb();

  reg resetn;
  reg clock;
  reg program_counter_increment;
  reg[3:0] alu_op;
  reg[15:0] alu_a_altern;
  reg[15:0] alu_b_altern;
  reg[3:0] alu_a_select;
  reg[3:0] alu_b_select;
  reg alu_a_source;
  reg alu_b_source;
  reg[3:0] alu_out_select;
  reg[1:0] alu_load_src;
  reg alu_store_to_mem;
  reg alu_store_to_stk;
  reg[3:0] vga_color_select;
  reg[3:0] vga_coord_select;

  wire[15:0] alu_output;
  wire[15:0] current_instruction;
  wire[15:0] signflag;
  wire[15:0] zeroflag;
  wire[15:0] overflow;
  wire[15:0] errorbit;
  wire[14:0] vga_color;
  wire[7:0] vga_x;
  wire[6:0] vga_y;
  wire[255:0] registers;

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

  always begin
    clock = 1'b0; #2; clock = 1'b1; #2;
  end

  initial begin

    $dumpfile("datapath_tb.vcd");
    $dumpvars;

    resetn = 1'b0;
    program_counter_increment = 1'b0;
    alu_op = 4'h0;
    alu_a_select = 4'h0;
    alu_b_select = 4'h0;
    alu_a_altern = 16'h0;
    alu_b_altern = 16'h0;
    alu_a_source = 1'b0;
    alu_b_source = 1'b0;
    alu_out_select = 4'h0;
    alu_load_src = 2'b00;
    alu_store_to_mem = 1'b0;
    alu_store_to_stk = 1'b0;
    vga_color_select = 4'h0;
    vga_coord_select = 4'h0;

    #6;

    // Try setting register 7 to 0 + 2
    resetn = 1'b1;
    program_counter_increment = 1'b1;
    alu_op = 4'h1;
    alu_a_select = 4'h7;
    alu_b_select = 4'hx;
    alu_a_altern = 16'hxxxx;
    alu_b_altern = 16'h7;
    alu_a_source = 1'b0;
    alu_b_source = 1'b1;
    alu_out_select = 4'h7;
    alu_load_src = 2'b01;

    #4;

    $finish;
  end

endmodule
