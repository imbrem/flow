module alu_control_word_decoder(
  input[54:0] control_word,
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

  assign {program_counter_increment,
    alu_op,
    alu_a_altern,
    alu_b_altern,
    alu_a_select,
    alu_b_select,
    alu_a_source,
    alu_b_source,
    alu_out_select,
    alu_load_src,
    alu_store_to_mem,
    alu_store_to_stk
  } = control_word;

endmodule
