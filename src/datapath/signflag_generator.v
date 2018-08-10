module signflag_generator(
  input[255:0] registers,
  output[15:0] signflag);

 genvar i;
 generate
 for(i = 0; i < 16; i = i + 1) begin: signflag_gen
	assign signflag[i] = registers[16*i + 15];
 end
 endgenerate

endmodule
