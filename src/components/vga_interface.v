module vga_interface(registers, vga_color_select, vga_coord_select, vga_color, vga_x, vga_y);

	input[255:0] registers;
	input[3:0] vga_color_select;
	input[3:0] vga_coord_select;
	output[14:0] vga_color;
	output[7:0] vga_x;
	output[6:0] vga_y;
	
	wire[15:0] vga_coord_src; // VGA coordinate source
	
	assign vga_color = registers[vga_color_select * 16 +: 15];
	assign vga_coord_src = registers[vga_coord_select * 16 +: 16];
	assign vga_x = vga_coord_src[7:0];
	assign vga_y = vga_coord_src[14:8];

endmodule