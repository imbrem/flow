module ALU(
  input[3:0] alu_op,
  input[15:0] a,
  input[15:0] b,
  output reg[15:0] c,
  output reg ofl,
  output reg err);

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

  wire[15:0] fadd_input_b = (alu_op == inst_fsub) ? (b ^ 16'h8000) : b;
  wire[15:0] fadd_result;
  wire fadd_ofl;
  wire[15:0] fmul_result;
  wire fmul_ofl;
  wire[15:0] fdiv_result;
  wire fdiv_err;
  wire[16:0] itof_input = (alu_op == inst_utof) ? a : {a[15], a};
  wire[15:0] itof_result;
  wire[15:0] ftoi_result;
  wire ftoi_ofl;

  always @(*) begin
    ofl = 1'b0;
    err = 1'b0;
    case(alu_op)
      inst_left: c = a;
      inst_iadd: {ofl, c} = a + b;
      inst_isub: c = a - b;
      inst_imul: {ofl, c} = a * b;
      inst_idiv: begin
        {ofl, c} = a / b;
        err = (b == 0);
      end
      inst_fadd: {ofl, c} = {fadd_ofl, fadd_result};
      inst_fsub: {ofl, c} = {fadd_ofl, fadd_result};
      inst_fmul: {ofl, c} = {fmul_ofl, fmul_result};
      inst_fdiv: {err, c} = {fdiv_err, fdiv_result};
      inst_band: c = a & b;
      inst_bior: c = a | b;
      inst_bxor: c = a ^ b;
      inst_ishl: begin
        if(b[15]) c = a >> (-b);
        else c = a << b;
      end
      inst_itof: c = itof_result;
      inst_utof: c = itof_result;
      inst_ftoi: {ofl, c} = {ftoi_ofl, ftoi_result};
    endcase
  end
  
  float16_adder fa(
    .a(a),
	 .b(b),
	 .c(fadd_result),
	 .of(fadd_ofl));

endmodule
