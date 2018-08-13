module unary_instruction_decoder(
  input[11:0] instruction,
  input[15:0] zeroflag,
  input[15:0] signflag,
  input[15:0] overflow,
  input[15:0] errorbit,
  output[54:0] control_word);

  reg[3:0] alu_op;
  reg[15:0] alu_a_altern;
  reg[15:0] alu_b_altern;
  reg[3:0] alu_a_select;
  reg[3:0] alu_b_select;
  reg alu_a_source;
  reg alu_b_source;

  alu_control_word_encoder unary_encoder(
    .program_counter_increment(1'b1),
    .alu_op(alu_op),
    .alu_a_altern(alu_a_altern),
    .alu_b_altern(alu_b_altern),
    .alu_a_select(alu_a_select),
    .alu_b_select(alu_b_select),
    .alu_a_source(alu_a_source),
    .alu_b_source(alu_b_source),
    .alu_out_select(instruction[3:0]),
    .alu_load_src(2'b01),
    .alu_store_to_mem(1'b0),
    .alu_store_to_stk(1'b0),
    .control_word(control_word));

  localparam
    inst_left = 4'h0,
    inst_iadd = 4'h1,
    inst_isub = 4'h2,
    inst_imul = 4'h3,
    inst_vgaa = 4'h4,
    inst_fadd = 4'h5,
    inst_fsub = 4'h6,
    inst_fmul = 4'h7,
    inst_bvga = 4'h8,
    inst_band = 4'h9,
    inst_bior = 4'hA,
    inst_bxor = 4'hB,
    inst_ishl = 4'hC,
    inst_itof = 4'hD,
    inst_utof = 4'hE,
    inst_ftoi = 4'hF;

  localparam
    inst_copy = 4'h0,
    inst_iszr = 4'h1,
    inst_isnz = 4'h2,
    inst_isnn = 4'h3,
    inst_isng = 4'h4,
    inst_isof = 4'h5,
    inst_isnf = 4'h6,
    inst_iser = 4'h7,
    inst_isne = 4'h8,
    inst_unot = 4'h9,
    inst_ineg = 4'hA,
    inst_uitf = 4'hB,
    inst_shlc = 4'hC,
    inst_shrc = 4'hD,
    inst_ufti = 4'hE,
    inst_cnst = 4'hF;

  localparam
    cid_zero = 4'h0,
    cid_one = 4'h1,
    cid_two = 4'h2,
    cid_three = 4'h3,
    cid_four = 4'h4,
    cid_five = 4'h5,
    cid_six = 4'h6,
    cid_seven = 4'h7,
    cid_eight = 4'h8,
    cid_fone = 4'h9,
    cid_sixt = 4'hA,
    cid_neg1 = 4'hB,
    cid_zrfl = 4'hC,
    cid_sgfl = 4'hD,
    cid_ovfl = 4'hE,
    cid_erfl = 4'hF;

  always @(*) begin
    alu_op = 4'h0; // LEFT
    alu_a_altern = 16'hxxxx;
    alu_b_altern = 16'hxxxx;
    alu_a_select = 4'hx;
    alu_b_select = 4'hx;
    alu_a_source = 1'bx;
    alu_b_source = 1'bx;
    case(instruction[11:8])
      inst_copy: begin
        alu_a_select = instruction[7:4];
        alu_a_source = 1'b0;
      end
      inst_iszr: begin
        alu_a_altern = {15'b0, zeroflag[instruction[7:4]]};
        alu_a_source = 1'b1;
      end
      inst_isnz: begin
        alu_a_altern = {15'b0, ~zeroflag[instruction[7:4]]};
        alu_a_source = 1'b1;
      end
      inst_isnn: begin
        alu_a_altern = {15'b0, ~signflag[instruction[7:4]]};
        alu_a_source = 1'b1;
      end
      inst_isng: begin
        alu_a_altern = {15'b0, signflag[instruction[7:4]]};
        alu_a_source = 1'b1;
      end
      inst_isof: begin
        alu_a_altern = {15'b0, overflow[instruction[7:4]]};
        alu_a_source = 1'b1;
      end
      inst_isnf: begin
        alu_a_altern = {15'b0, ~overflow[instruction[7:4]]};
        alu_a_source = 1'b1;
      end
      inst_iser: begin
        alu_a_altern = {15'b0, errorbit[instruction[7:4]]};
        alu_a_source = 1'b1;
      end
      inst_isne: begin
        alu_a_altern = {15'b0, ~errorbit[instruction[7:4]]};
        alu_a_source = 1'b1;
      end
      inst_unot: begin
        alu_a_select = instruction[7:4];
        alu_b_altern = 16'hFFFF;
        alu_op = inst_bxor;
        alu_a_source = 1'b0;
        alu_b_source = 1'b1;
      end
      inst_ineg: begin
        alu_a_altern = 16'h0;
        alu_b_select = instruction[7:4];
        alu_a_source = 1'b1;
        alu_b_source = 1'b0;
        alu_op = inst_isub;
      end
      inst_ufti: begin
        alu_a_select = instruction[7:4];
        alu_op = inst_ftoi;
        alu_a_source = 1'b0;
      end
      inst_shlc: begin
        alu_a_select = instruction[3:0];
        alu_b_altern = instruction[7:4];
        alu_op = inst_ishl;
        alu_a_source = 1'b0;
        alu_b_source = 1'b1;
      end
      inst_shrc: begin
        alu_a_select = instruction[3:0];
        alu_b_altern = -{12'b0, instruction[7:4]};
        alu_op = inst_ishl;
        alu_a_source = 1'b0;
        alu_b_source = 1'b1;
      end
      inst_uitf: begin
        alu_a_select = instruction[7:4];
        alu_a_source = 1'b0;
        alu_op = inst_itof;
      end
      inst_cnst: begin
        alu_a_source = 1'b1;
        case(instruction[7:4])
          cid_zero: alu_a_altern = 16'h0;
          cid_one: alu_a_altern = 16'h1;
          cid_two: alu_a_altern = 16'h2;
          cid_three: alu_a_altern = 16'h3;
          cid_four: alu_a_altern = 16'h4;
          cid_five: alu_a_altern = 16'h5;
          cid_six: alu_a_altern = 16'h6;
          cid_seven: alu_a_altern = 16'h7;
          cid_eight: alu_a_altern = 16'h8;
          cid_fone: alu_a_altern = 16'h3C00;
          cid_sixt: alu_a_altern = 16'h10;
          cid_neg1: alu_a_altern = 16'h8000;
          cid_zrfl: alu_a_altern = zeroflag;
          cid_sgfl: alu_a_altern = signflag;
          cid_ovfl: alu_a_altern = overflow;
          cid_erfl: alu_a_altern = errorbit;
        endcase
      end
    endcase
  end

endmodule
