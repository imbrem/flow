module register_selector(input[3:0] i, input[255:0] r, output[15:0] v);
  assign v = r[i*16 +: 16];
endmodule
