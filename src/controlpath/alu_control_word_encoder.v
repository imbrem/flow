module alu_control_word_encoder(
  input program_counter_increment,
  input[3:0] alu_op,
  input[15:0] alu_a_altern,
  input[15:0] alu_b_altern,
  input[3:0] alu_a_select,
  input[3:0] alu_b_select,
  input alu_a_source,
  input alu_b_source,
  input[3:0] alu_out_select,
  input[1:0] alu_load_src,
  input alu_store_to_mem,
  input alu_store_to_stk,
  output[54:0] control_word
  );

  assign control_word = {program_counter_increment,
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
  };

endmodule
