module float16_adder(a, b, c, of);

  input[15:0] a;
  input[15:0] b;
  output[15:0] c;
  output of;

  wire sign_a = a[15];
  wire sign_b = b[15];
  wire[4:0] exp_a = a[14:10];
  wire[4:0] exp_b = b[14:10];
  wire a_normal = (exp_a != 0);
  wire b_normal = (exp_b != 0);
  wire signed[11:0] usig_a = {1'b0, a_normal, a[9:0]};
  wire signed[11:0] usig_b = {1'b0, b_normal, b[9:0]};

  wire signed[11:0] sig_a = sign_a?(-usig_a):usig_a;
  wire signed[11:0] sig_b = sign_b?(-usig_b):usig_b;

  wire b_gt_a = exp_b > exp_a;

  sorted_float_adder sf(
    .exp_min(b_gt_a ? exp_a : exp_b),
    .sig_min(b_gt_a ? sig_a : sig_b),
    .exp_max(b_gt_a ? exp_b : exp_a),
    .sig_max(b_gt_a ? sig_b : sig_a),
    .out(c),
	 .of(of)
  );

endmodule
