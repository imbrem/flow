module control_word_selector(
  input[3:0] selector,
  input[54:0] null_control_word,
  input[54:0] binary_control_word,
  input[54:0] unary_control_word,
  input[54:0] increment_control_word,
  input[54:0] jump_control_word,
  output reg[54:0] control_word
  );

  localparam inst_null = 4'h0, inst_unar = 4'hD, inst_incr = 4'hE,
    inst_jump = 4'hF;

  always @(*) begin
    case(selector)
      inst_null: control_word = null_control_word;
      inst_unar: control_word = unary_control_word;
      inst_incr: control_word = increment_control_word;
      inst_jump: control_word = jump_control_word;
      default: control_word = binary_control_word;
    endcase
  end

endmodule
