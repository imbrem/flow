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

  localparam
    inst_left = 4'h0,
    inst_iadd = 4'h1;

  localparam
    jz = 2'h0,
    js = 2'h1,
    jo = 2'h2,
    je = 2'h3;

  initial begin

    $dumpfile("jump_instruction_tb.vcd");
    $dumpvars;

    zeroflag = 16'b0101010101010101;
    signflag = 16'b0;
    overflow = 16'b0;
    errorbit = 16'b0;

    instruction = {2'b00, jz, 4'h5, 4'h6};

    #1 if(~program_counter_increment) $display("D-JZ 5 6 jumps");
    if(alu_op != inst_left) $display("D-JZ 5 6 does not set ALU to LEFT");
    if(alu_a_select != 4'h6)
      $display("D-JZ 5 6 sets A to %h (expected 6)", alu_a_select);
    if(alu_b_select != 4'h0)
      $display("D-JZ 5 6 sets B to %h (expected 0)", alu_b_select);
    if(alu_out_select != 4'h0)
      $display("D-JZ 5 6 sets C to %h (expected 0)", alu_out_select);
    if(alu_load_src != 2'b00)
      $display("D-JZ 5 6 writes to program counter");

    instruction = {2'b01, jz, 4'h5, 4'h6};

    #1 if(program_counter_increment) $display("D-JNZ 5 6 does not jump");
    if(alu_op != inst_left) $display("D-JNZ 5 6 does not set ALU to LEFT");
    if(alu_a_select != 4'h6)
      $display("D-JNZ 5 6 sets A to %h (expected 6)", alu_a_select);
    if(alu_b_select != 4'h0)
      $display("D-JNZ 5 6 sets B to %h (expected 0)", alu_b_select);
    if(alu_out_select != 4'h0)
      $display("D-JNZ 5 6 sets C to %h (expected 0)", alu_out_select);
    if(alu_load_src != 2'b01)
      $display("D-JNZ 5 6 does not write to program counter");

    instruction = {2'b10, jz, 4'h5, 4'h6};

    #1 if(~program_counter_increment) $display("O-JZ 5 6 jumps");
    if(alu_op != inst_iadd) $display("O-JZ 5 6 does not set ALU to IADD");
    if(alu_a_select != 4'h6)
      $display("O-JZ 5 6 sets A to %h (expected 6)", alu_a_select);
    if(alu_b_select != 4'h0)
      $display("O-JZ 5 6 sets B to %h (expected 0)", alu_b_select);
    if(alu_out_select != 4'h0)
      $display("O-JZ 5 6 sets C to %h (expected 0)", alu_out_select);
    if(alu_load_src != 2'b00)
      $display("O-JZ 5 6 writes to program counter");

    instruction = {2'b11, jz, 4'h5, 4'h6};

    #1 if(program_counter_increment) $display("O-JNZ 5 6 does not jump");
    if(alu_op != inst_iadd) $display("O-JNZ 5 6 does not set ALU to IADD");
    if(alu_a_select != 4'h6)
      $display("O-JNZ 5 6 sets A to %h (expected 6)", alu_a_select);
    if(alu_b_select != 4'h0)
      $display("O-JNZ 5 6 sets B to %h (expected 0)", alu_b_select);
    if(alu_out_select != 4'h0)
      $display("O-JNZ 5 6 sets C to %h (expected 0)", alu_out_select);
    if(alu_load_src != 2'b01)
      $display("O-JNZ 5 6 does not write to program counter");

    $finish;

  end

endmodule
