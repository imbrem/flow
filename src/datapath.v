module datapath(
  input resetn,
  input clock,
  // Program counter increment
  input program_counter_increment,
  // ALU driver
  input[3:0] alu_op,
  input[15:0] alu_a_altern,
  input[15:0] alu_b_altern,
  input[3:0] alu_a_select,
  input[3:0] alu_b_select,
  input alu_a_source,
  input alu_b_source,
  // ALU output controller
  input[3:0] alu_out_select,
  input[1:0] alu_load_src,
  input alu_store_to_mem,
  input alu_store_to_stk,
  // ALU output
  output[15:0] alu_output,
  // VGA controller
  input[3:0] vga_color_select,
  input[3:0] vga_coord_select,
  // Current instruction
  output[15:0] current_instruction,
  // Flag registers
  output[15:0] signflag,
  output[15:0] zeroflag,
  output reg[15:0] overflow,
  output reg[15:0] errorbit,
  // VGA outputs
  output[14:0] vga_color,
  output[7:0] vga_x,
  output[6:0] vga_y,
  // Register view
  output[255:0] registers);

  wire[15:0] selected_a;
  wire[15:0] selected_b;
  wire[15:0] selected_c;
  wire alu_ofl;
  wire alu_err;

  ALU A(
    .alu_op(alu_op),
    .a(alu_a_source ? alu_a_altern : selected_a),
    .b(alu_b_source ? alu_b_altern : selected_b),
    .c(alu_output),
    .ofl(alu_ofl),
    .err(alu_err));

  register_selector a_selector(alu_a_select, registers, selected_a);
  register_selector b_selector(alu_b_select, registers, selected_b);
  register_selector c_selector(alu_out_select, registers, selected_c);

  zeroflag_generator Z(registers, zeroflag);
  signflag_generator S(registers, signflag);

  reg[15:0] register[15:0];

  wire non_register = alu_load_src[1];
  wire[15:0] address_value = alu_load_src[0] ? at_stack : at_memory;
  wire[15:0] update_value = non_register ? address_value : alu_output;

  genvar i;
  generate
    for(i = 1; i < 16; i = i + 1) begin: general_purpose_register_update

        always @(negedge clock) begin
          if(!resetn) begin
            register[i] <= 16'b0;
				overflow[i] <= 1'b0;
				errorbit[i] <= 1'b0;
          end
          else if(i == alu_out_select & alu_load_src != 2'b00) begin
            register[i] = update_value;
				overflow[i] = alu_ofl;
				errorbit[i] = alu_err;
          end
        end

        assign registers[i*16 +: 16] = register[i];

    end
  endgenerate

  always @(negedge clock) begin
    if(!resetn) begin
      register[0] <= 16'h0;
		overflow[0] <= 1'b0;
		errorbit[0] <= 1'b0;
    end
    else begin
      if(4'h0 == alu_out_select & alu_load_src != 2'b00) begin
        register[0] <= update_value + program_counter_increment;
		  overflow[0] <= alu_ofl;
		  errorbit[0] <= alu_err;
      end
      else begin
        register[0] <= register[0] + program_counter_increment;
      end
    end
  end
  assign registers[15:0] = register[0];

  wire[15:0] at_memory;
  wire[15:0] at_stack;

  memory M(
      .clock(clock),
      .program_counter(registers[15:0]),
      .address(alu_output),
      .value(selected_c),
      .memory_store_enable(alu_store_to_mem),
      .stack_store_enable(alu_store_to_stk),
      .current_instruction(current_instruction),
      .at_memory(at_memory),
      .at_stack(at_stack));

  vga_interface V(
    .registers(registers),
    .vga_color_select(vga_color_select),
    .vga_coord_select(vga_coord_select),
    .vga_color(vga_color),
    .vga_x(vga_x),
    .vga_y(vga_y));


endmodule
