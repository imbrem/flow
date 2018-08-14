module abs_float_multiplier(exp_a, exp_b, sig_a, sig_b, out, of);

  input[4:0] exp_a;
  input[4:0] exp_b;
  input[10:0] sig_a;
  input[10:0] sig_b;
  output reg[14:0] out;
  output of;

  wire signed[6:0] exp_c_na = exp_a + exp_b - 7'hF;

  wire[20:0] ext_sig_c = sig_a * sig_b;
  reg [3:0] shf;
  reg subn;

  always @(*) begin
    subn = 0;
    casez(ext_sig_c)
      20'b1zzzzzzzzzzzzzzzzzzz: shf = 4'h9;
      20'b01zzzzzzzzzzzzzzzzzz: shf = 4'h8;
      20'b001zzzzzzzzzzzzzzzzz: shf = 4'h7;
      20'b0001zzzzzzzzzzzzzzzz: shf = 4'h6;
      20'b00001zzzzzzzzzzzzzzz: shf = 4'h5;
      20'b000001zzzzzzzzzzzzzz: shf = 4'h4;
      20'b0000001zzzzzzzzzzzzz: shf = 4'h3;
      20'b00000001zzzzzzzzzzzz: shf = 4'h2;
      20'b000000001zzzzzzzzzzz: shf = 4'h1;
      20'b0000000001zzzzzzzzzz: shf = 4'h0;
      default : begin subn = 1; shf = 4'h0; end
    endcase
  end

  wire[9:0] sig_c = ext_sig_c[shf + 10 -: 10];
  wire signed[6:0] exp_c_sh = exp_c_na + shf;
  wire[6:0] uexpcsh = -exp_c_sh;
  assign of = exp_c_sh > 5'b11111;

  always @(*) begin
    if(subn) out = 14'b0;
    else if(exp_c_sh < 0) out = {5'b0, sig_c >> uexpcsh};
    else out = {exp_c_sh[4:0], sig_c};
  end

endmodule
