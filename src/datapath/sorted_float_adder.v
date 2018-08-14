module sorted_float_adder(exp_min, sig_min, exp_max, sig_max, out, of);

  input[4:0] exp_min;
  input signed[11:0] sig_min;
  input[4:0] exp_max;
  input signed[11:0] sig_max;

  output reg[15:0] out;
  output of;

  // Extend minimum and maximum signed significands by 2 bits, before and after
  wire signed[13:0] extended_max = {sig_max[11], sig_max, 1'b0};
  wire signed[13:0] extended_min = {sig_min[11], sig_min, 1'b0};

  // Arithemtically shift minimum significand backwards
  wire signed[13:0] shifted_min = extended_min >>> (exp_max - exp_min);

  // Add significands
  wire signed[13:0] addition_result = extended_max + shifted_min;
  wire signed[13:0] neg_addition_result = -addition_result;

  // Get output sign, take absolute value of significand
  wire sign_c = addition_result[13];
  wire[12:0] abs_addition_result = sign_c ? neg_addition_result[12:0] : addition_result[12:0];

  // Calculate significand exponent
  reg [3:0] shift;
  always @(*) begin
    casez(abs_addition_result)
      13'b1zzzzzzzzzzzz: shift = 4'hD;
      13'b01zzzzzzzzzzz: shift = 4'hC;
      13'b001zzzzzzzzzz: shift = 4'hB;
      13'b0001zzzzzzzzz: shift = 4'hA;
      13'b00001zzzzzzzz: shift = 4'h9;
      13'b000001zzzzzzz: shift = 4'h8;
      13'b0000001zzzzzz: shift = 4'h7;
      13'b00000001zzzzz: shift = 4'h6;
      13'b000000001zzzz: shift = 4'h5;
      13'b0000000001zzz: shift = 4'h4;
      13'b00000000001zz: shift = 4'h3;
      13'b000000000001z: shift = 4'h2;
      13'b0000000000001: shift = 4'h1;
      default: shift = 4'h0;
    endcase
  end
  wire signed[6:0] exp_c = exp_max - 6'hC + shift;
  assign of = exp_c > 5'b11111;
  
  wire[22:0] ext_addition_result = {abs_addition_result, 10'b0};
  wire[9:0] sig_addition_result =
    shift ? (ext_addition_result[shift - 1 +: 10]) : 10'b0;


  always @(*) begin
    if(exp_c > 0) begin
      out = {sign_c, exp_c[4:0], sig_addition_result};
    end
    else begin
      out = {sign_c, 5'b0, abs_addition_result[9:0]};
    end
  end


endmodule
