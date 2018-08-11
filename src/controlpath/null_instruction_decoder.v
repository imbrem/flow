module null_instruction_decoder(
  input[11:0] instruction,
  input[15:0] switches,
  output[54:0] control_word);

  wire[3:0] null_opcode = instruction[11:8];
  wire[3:0] alu_opcode;
  wire[3:0] memory_alu_opcode;

  wire[54:0] ujmp_word;
  wire[54:0] null_word;

  localparam
    inst_left = 4'h0,
    inst_iadd = 4'h1;

  localparam
    // Specials
    ujmp = 4'b0000, // Unconditional jump
    ldsw = 4'b0001, // Switch arithmetic to register
    dvga = 4'b0010, // Display VGA (color, coordinate) (not handled here)
    swcl = 4'b0011, // Switch clock (not handled here)

    // RESERVED

    // Loads
    rmem = 4'b1000, // Read memory to register
    wmem = 4'b1100, // Write register to memory
    rstk = 4'b1010, // Read stack to register
    wstk = 4'b1110, // Write register to stack
    rmof = 4'b1001, // Offset read memory to register
    wmof = 4'b1101, // Offset write register to memory
    rsof = 4'b1011, // Offset read stack to register
    wsof = 4'b1111; // Offset write stack to register

  assign control_word = (null_opcode == ujmp) ? ujmp_word : null_word;
  assign memory_alu_opcode = null_opcode[0] ? inst_iadd : inst_left;
  assign alu_opcode = (null_opcode == ldsw) ?
    instruction[7:4] : memory_alu_opcode;

  wire is_memop = null_opcode[3];
  wire is_stack = null_opcode[1] & is_memop;
  wire is_store = null_opcode[2] & is_memop;

  alu_control_word_encoder noop_encoder(
    .program_counter_increment(1'b1),
    .alu_op(4'hx),
    .alu_a_altern(16'hxxxx),
    .alu_b_altern(16'hxxxx),
    .alu_a_select(4'hx),
    .alu_b_select(4'hx),
    .alu_a_source(1'bx),
    .alu_b_source(1'bx),
    .alu_out_select(4'hx),
    .alu_load_src(2'b00),
    .alu_store_to_mem(1'b0),
    .alu_store_to_stk(1'b0),
    .control_word(ujmp_word));

	/*
  unconditional_jump_decoder jump_decoder(
    .instruction(instruction),
    .control_word(ujmp_word));
	*/

  alu_control_word_encoder null_encoder(
      .program_counter_increment(1'b1),
      .alu_op(alu_opcode),
      .alu_a_altern(switches),
      .alu_b_altern(16'hxxxx),
      .alu_a_select(instruction[7:4]),
      .alu_b_select(instruction[3:0]),
      .alu_a_source(null_opcode == ldsw),
      .alu_b_source(1'b0),
      .alu_out_select(is_store ? instruction[7:4] : instruction[3:0]),
      .alu_load_src(
        is_memop ?
          {~is_store, is_stack & ~is_store} : {1'b0, null_opcode == ldsw}
        ),
      .alu_store_to_mem(~is_stack & is_store),
      .alu_store_to_stk(is_stack & is_store),
      .control_word(null_word));


endmodule
