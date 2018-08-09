module hex_decoder(input[3:0] h, output reg[6:0] s);

	always @(*) begin
		case(h)
			4'h0: s =  7'b0000001;
			4'h1: s =  7'b1001111;
			4'h2: s =  7'b0010010;
			4'h3: s =  7'b0000110;
			4'h4: s =  7'b1001100;
			4'h5: s =  7'b0100100;
			4'h6: s =  7'b0100000;
			4'h7: s =  7'b0001111;
			4'h8: s =  7'b0000000;
			4'h9: s =  7'b0001100;
			4'hA: s =  7'b0001000;
			4'hB: s =  7'b1100000;
			4'hC: s =  7'b0110001;
			4'hD: s =  7'b1000010;
			4'hE: s =  7'b0110000;
			4'hF: s =  7'b0111000;
		endcase
	end

endmodule