module bit_updater(
  input[3:0] select,
  input enable,
  input value,
  input[15:0] r,
  output reg[15:0] u
  );

  always @(*) begin
    u = r;
    if(enable) u[select] = value;
  end

endmodule
