module zeroflag_generator(
  input[255:0] registers,
  output[15:0] zeroflag);

 genvar i;
 generate
 for(i = 0; i < 16; i = i + 1) begin: zeroflag_gen
	assign zeroflag[i] = ~(|registers[16*i +: 16]);
 end
 endgenerate

endmodule
