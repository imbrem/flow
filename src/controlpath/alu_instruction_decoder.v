module alu_instruction_decoder(
    input[15:0] instruction,
    input[15:0] zeroflag,
    input[15:0] signflag,
    input[15:0] overflow,
    input[15:0] errorbit,
    input[15:0] switches,
    output program_counter_increment,
    output[3:0] alu_op,
    output[15:0] alu_a_altern,
    output[15:0] alu_b_altern,
    output[3:0] alu_a_select,
    output[3:0] alu_b_select,
    output alu_a_source,
    output alu_b_source,
    output[3:0] alu_out_select,
    output[1:0] alu_load_src,
    output alu_store_to_mem,
    output alu_store_to_stk);

    wire[54:0] null_control_word;
    wire[54:0] binary_control_word;
    wire[54:0] unary_control_word;
    wire[54:0] increment_control_word;
    wire[54:0] jump_control_word;

    wire[54:0] control_word;

    jump_instruction_decoder jump_decoder(
        .instruction(instruction[11:0]),
        .zeroflag(zeroflag),
        .signflag(signflag),
        .overflow(overflow),
        .errorbit(errorbit),
        .control_word(jump_control_word));

    null_instruction_decoder null_decoder(
        .instruction(instruction[11:0]),
        .switches(switches),
        .control_word(null_control_word));

    control_word_selector S(
      .selector(instruction[15:12]),
      .null_control_word(null_control_word),
      .binary_control_word(binary_control_word),
      .unary_control_word(unary_control_word),
      .increment_control_word(increment_control_word),
      .jump_control_word(jump_control_word),
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

    alu_control_word_encoder binary_encoder(
      .program_counter_increment(1'b1),
      .alu_op(instruction[15:12]),
      .alu_a_altern(16'hxxxx),
      .alu_b_altern(16'hxxxx),
      .alu_a_select(instruction[11:8]),
      .alu_b_select(instruction[7:4]),
      .alu_a_source(1'b0),
      .alu_b_source(1'b0),
      .alu_out_select(instruction[3:0]),
      .alu_load_src(2'b01), // Store to register
      .alu_store_to_mem(1'b0),
      .alu_store_to_stk(1'b0),
      .control_word(binary_control_word));

    wire isgn = instruction[11];
    wire[15:0] sign_extended_increment = {
      isgn, isgn, isgn, isgn, isgn, isgn, isgn, isgn, instruction[11:4]
    };

    alu_control_word_encoder increment_encoder(
      .program_counter_increment(1'b1),
      .alu_op(4'h1),
      .alu_a_altern(16'hxxxx),
      .alu_b_altern(sign_extended_increment),
      .alu_a_select(instruction[3:0]),
      .alu_b_select(4'hx),
      .alu_a_source(1'b0),
      .alu_b_source(1'b1),
      .alu_out_select(instruction[3:0]),
      .alu_load_src(2'b01),
      .alu_store_to_mem(1'b0),
      .alu_store_to_stk(1'b0),
      .control_word(increment_control_word));

endmodule
