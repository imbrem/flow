module jump_instruction_tb();

  reg[11:0] instruction;
  reg[15:0] zeroflag;
  reg[15:0] signflag;
  reg[15:0] overflow;
  reg[15:0] errorbit;

  wire[54:0] control_word;
  wire program_counter_increment;
  wire[3:0] alu_op;
  wire[15:0] alu_a_altern;
  wire[15:0] alu_b_altern;
  wire[3:0] alu_a_select;
  wire[3:0] alu_b_select;
  wire alu_a_source;
  wire alu_b_source;
  wire[3:0] alu_out_select;
  wire[1:0] alu_load_src;
  wire alu_store_to_stk;
  wire alu_store_to_mem;

  jump_instruction_decoder jump_decoder(
      .instruction(instruction[11:0]),
      .zeroflag(zeroflag),
      .signflag(signflag),
      .overflow(overflow),
      .errorbit(errorbit),
      .control_word(control_word));

  alu_control_word_decoder D(
      .control_word(control_word),
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
      .alu_store_to_stk(alu_store_to_stk));


  initial begin

    $dumpfile("jump_instruction_tb.vcd");
    $dumpvars;

    $finish;

  end

endmodule
