module fpga_top(
  input[9:0] SW,
  input[3:0] KEY,
  input CLOCK_50,
  output[9:0] LEDR,
  output[6:0] HEX0,
  output[6:0] HEX1,
  output[6:0] HEX2,
  output[6:0] HEX3,
  output[6:0] HEX4,
  output[6:0] HEX5,
  output VGA_CLK,
  output VGA_HS,
  output VGA_VS,
  output VGA_BLANK_N,
  output VGA_SYNC_N,
  output[9:0]	VGA_R,
  output[9:0]	VGA_G,
  output[9:0]	VGA_B);

  reg[15:0] switch_register;
  reg[4:0] offset;
  reg[1:0] speed_select;
  reg clock_lock;

  assign LEDR[9] = clock_lock;
  assign LEDR[8] = |switch_register;

  wire resetn = KEY[0];
  wire load = ~KEY[1];
  wire user_clock = KEY[2];
  wire switch_clock;
  wire current_clock;

  wire special = SW[9];
  wire top_select = SW[8];

  wire[15:0] zeroflag;
  wire[15:0] signflag;
  wire[15:0] overflow;
  wire[15:0] errorbit;

  wire[255:0] registers;
  wire[15:0] alu_output;
  wire[15:0] alu_word;
  wire[15:0] alu_a_altern;
  wire[15:0] alu_b_altern;
  wire alu_a_source;
  wire alu_b_source;
  wire alu_store_to_mem;
  wire alu_store_to_stk;
  wire[1:0] alu_load_src;
  wire[15:0] current_instruction;
  wire program_counter_increment;
  wire vga_plot;
  wire vga_resetn;
  wire[14:0] vga_color;
  wire[7:0] vga_x;
  wire[6:0] vga_y;
  wire[2:0] current_state;

  `ifdef FLOW_NICER_REGISTER_VIEW
  wire[15:0] reg0 = registers[15:0];
  wire[15:0] reg1 = registers[31:16];
  wire[15:0] reg2 = registers[47:32];
  wire[15:0] reg3 = registers[63:48];
  wire[15:0] reg4 = registers[79:64];
  wire[15:0] reg5 = registers[95:80];
  wire[15:0] reg6 = registers[111:96];
  wire[15:0] reg7 = registers[127:112];
  wire[15:0] reg8 = registers[143:128];
  wire[15:0] reg9 = registers[159:144];
  wire[15:0] regA = registers[175:160];
  wire[15:0] regB = registers[191:176];
  wire[15:0] regC = registers[207:192];
  wire[15:0] regD = registers[223:208];
  wire[15:0] regE = registers[239:224];
  wire[15:0] regF = registers[255:240];
  `endif

  wire[255:0] display = {
    16'b0,
    errorbit,
    overflow,
    signflag,
  	zeroflag,
  	{9'b0, vga_y},
  	{8'b0, vga_x},
  	{1'b0, vga_color},
  	alu_output,
  	alu_b_altern,
  	alu_a_altern,
  	alu_word,
  	current_instruction,
  	switch_register
  };

  wire clock23 = counter[22];
  wire clock22 = counter[21];
  wire clock21 = counter[20];
  reg[22:0] counter;
  reg clock;

  always @(posedge CLOCK_50) begin
	counter <= counter + 23'b1;
  end

  always @(*) begin
    case(speed_select)
      2'b00: clock = CLOCK_50;
      2'b01: clock = clock21;
      2'b10: clock = clock22;
      2'b11: clock = clock23;
    endcase
  end

  flow F(
    .resetn(resetn),
    .clock(clock),
    .user_clock(user_clock),
    .switch_clock(switch_clock),
    .clock_lock(clock_lock),
    .switches(switch_register),
    .current_state(current_state),
    .registers(registers),
    .zeroflag(zeroflag),
    .signflag(signflag),
    .overflow(overflow),
    .errorbit(errorbit),
    .vga_color(vga_color),
    .vga_x(vga_x),
    .vga_y(vga_y),
    .vga_plot(vga_plot),
    .vga_resetn(vga_resetn),
    .current_instruction(current_instruction),
    .program_counter_increment(program_counter_increment),
    .alu_word(alu_word),
    .alu_a_altern(alu_a_altern),
    .alu_b_altern(alu_b_altern),
    .alu_a_source(alu_a_source),
    .alu_b_source(alu_b_source),
    .alu_output(alu_output),
    .alu_store_to_mem(alu_store_to_mem),
    .alu_store_to_stk(alu_store_to_stk),
	 .alu_load_src(alu_load_src));

  wire[15:0] slice;

  register_selector display_selector(
      offset[3:0], offset[4] ? display : registers, slice);

  hex_decoder h0(slice[3:0], HEX0);
  hex_decoder h1(slice[7:4], HEX1);
  hex_decoder h2(slice[11:8], HEX2);
  hex_decoder h3(slice[15:12], HEX3);
  hex_decoder h4(offset[3:0], HEX4);
  hex_decoder h5({3'b0, offset[4]}, HEX5);

  wire[7:0] switch_view = top_select ? switch_register[7:0] : switch_register[15:8];
  wire[15:0] flags = {
							alu_a_source,
							alu_b_source,
							alu_store_to_mem,
							alu_store_to_stk,
							alu_load_src,
							switch_clock,
							user_clock,
							current_state,
							program_counter_increment,
							4'b0
							};
  wire[7:0] flag_slice = top_select ? flags[15:8] : flags[7:0];
  assign LEDR[7:0] = special ? flag_slice : switch_view;


  always @(posedge CLOCK_50) begin
    if(special) begin
      offset <= SW[4:0];
      clock_lock <= SW[5];
      speed_select <= SW[7:6];
    end
    else if(load) begin
      if(top_select) begin
        switch_register[15:8] <= SW[7:0];
      end
      else begin
        switch_register[7:0] <= SW[7:0];
      end
    end
  end

  `ifndef mock_memory

  vga_adapter VGA(
    .resetn(resetn),
    .clock(CLOCK_50),
    .colour(vga_color),
    .x(vga_x),
    .y(vga_y),
    .plot(vga_plot),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_BLANK(VGA_BLANK_N),
    .VGA_SYNC(VGA_SYNC_N),
    .VGA_CLK(VGA_CLK));
  defparam VGA.RESOLUTION = "160x120";
  defparam VGA.MONOCHROME = "FALSE";
  defparam VGA.BITS_PER_COLOUR_CHANNEL = 5;
  defparam VGA.BACKGROUND_IMAGE = "black.mif";


  `endif

endmodule
