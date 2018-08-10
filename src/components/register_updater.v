module register_updater(
  input[3:0] select,
  input enable,
  input[15:0] value,
  input[255:0] r,
  output reg[255:0] u);

  always @(*) begin
    u = r;
    if(enable) u[16*select +: 16] = value;
  end

endmodule
