module float16_multiplier(a, b, c, of);

  input[15:0] a;
  input[15:0] b;
  output[15:0] c;
  output of;

  wire sign_a = a[15];
  wire sign_b = b[15];
  wire sign_c = sign_a ^ sign_b;

  wire[4:0] exp_a = a[14:10];
  wire[4:0] exp_b = b[14:10];
  wire nrm_a = (exp_a != 0);
  wire nrm_b = (exp_b != 0);
  wire[10:0] sig_a = {nrm_a, a[9:0]};
  wire[10:0] sig_b = {nrm_b, b[9:0]};

  wire[14:0] abs_flt;

  abs_float_multiplier afm (
      .exp_a(exp_a), .exp_b(exp_b), .sig_a(sig_a), .sig_b(sig_b), .out(abs_flt), .of(of)
  );

  assign c = {sign_c, abs_flt};

endmodule
