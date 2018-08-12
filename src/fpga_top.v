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
  reg clock_lock;

  assign LEDR[9] = clock_lock;
  assign LEDR[8] = |switch_register;

  wire resetn = KEY[0];
  wire load = ~KEY[1];
  wire user_clock = KEY[2];
  wire switch_clock = ~KEY[3];
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

  flow F(
    .resetn(resetn),
    .clock(CLOCK_50),
    .user_clock(user_clock),
    .switch_clock(switch_clock),
    .clock_lock(clock_lock),
    .switches(switch_register),
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
  wire[7:0] flag_slice = {alu_a_source,
								  alu_b_source,
								  alu_store_to_mem,
								  alu_store_to_stk,
								  alu_load_src,
								  switch_clock,
								  user_clock,
								  };
  assign LEDR[7:0] = special ? flag_slice : switch_view;


  always @(posedge CLOCK_50) begin
    if(special) begin
      offset <= SW[4:0];
      clock_lock <= SW[5];
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

endmodule
