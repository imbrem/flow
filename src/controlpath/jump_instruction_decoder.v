module jump_instruction_decoder(
  input[11:0] instruction,
  input[15:0] zeroflag,
  input[15:0] signflag,
  input[15:0] overflow,
  input[15:0] errorbit,
  output[54:0] control_word);

  wire[3:0] jump_op = instruction[11:8];
  wire jump_add = jump_op[3];
  wire[3:0] alu_op = jump_add ? inst_iadd : inst_left;

  wire[1:0] jump_sw_select = jump_op[1:0];
  wire jump_invert = jump_op[2];

  wire[3:0] sw_reg = instruction[7:4];
  wire sw_zero = zeroflag[sw_reg];
  wire sw_sign = signflag[sw_reg];
  wire sw_over = overflow[sw_reg];
  wire sw_errb = errorbit[sw_reg];

  reg jump_sw;

  wire jump = jump_sw ^ jump_invert;

  alu_control_word_encoder jump_encoder(
      .program_counter_increment(~jump),
      .alu_op(alu_op),
      .alu_a_altern(16'hxxxx),
      .alu_b_altern(16'hxxxx),
      .alu_a_select(instruction[3:0]),
      .alu_b_select(4'h0),
      .alu_a_source(1'b0),
      .alu_b_source(1'b0),
      .alu_out_select(4'h0),
      .alu_load_src({1'b0, jump}),
      .alu_store_to_mem(1'b0),
      .alu_store_to_stk(1'b0),
      .control_word(control_word));

  localparam
    inst_left = 4'h0,
    inst_iadd = 4'h1,
    inst_isub = 4'h2,
    inst_imul = 4'h3,
    inst_idiv = 4'h4,
    inst_fadd = 4'h5,
    inst_fsub = 4'h6,
    inst_fmul = 4'h7,
    inst_fdiv = 4'h8,
    inst_band = 4'h9,
    inst_bior = 4'hA,
    inst_bxor = 4'hB,
    inst_ishl = 4'hC,
    inst_itof = 4'hD,
    inst_utof = 4'hE,
    inst_ftoi = 4'hF;

  localparam
    jz = 2'h0,
    js = 2'h1,
    jo = 2'h2,
    je = 2'h3;

    always @(*) begin
      case(jump_sw_select)
        jz: jump_sw = sw_zero;
        js: jump_sw = sw_sign;
        jo: jump_sw = sw_over;
        je: jump_sw = sw_errb;
      endcase
    end

endmodule
