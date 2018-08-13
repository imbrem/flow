module controlpath(
  input resetn,
  // Timing controls
  input clock,
  input user_clock,
  input clock_lock,
  output switch_clock,
  output reg[2:0] current_state,
  // Current instruction
  input[15:0] current_instruction,
  // Switch register
  input[15:0] switches,
  // Flag registers
  input[15:0] signflag,
  input[15:0] zeroflag,
  input[15:0] overflow,
  input[15:0] errorbit,
  // Program counter increment (yes/no)
  output program_counter_increment,
  // ALU driver
  output[3:0] alu_op,
  output[15:0] alu_a_altern, // Alternative input A
  output[15:0] alu_b_altern, // Alternative input B
  output[3:0] alu_a_select, // Register for input A
  output[3:0] alu_b_select, // Register for input B
  output alu_a_source, // Source for input A (reg/alt)
  output alu_b_source, // Source for input B (reg/alt)
  // ALU output controller
  output[3:0] alu_out_select, // Destination register
  output reg[1:0] alu_load_src, // Load source (self, alu, mem, stk)
  output alu_store_to_mem, // Store reg[C] to mem[ALU]
  output alu_store_to_stk, // Store reg[C] to stk[ALU]
  // VGA driver
  output[3:0] vga_color_select,
  output[3:0] vga_coord_select,
  output vga_plot,
  output vga_resetn);

  wire[1:0] load_src;
  wire increment;
  reg next_instruction;

  assign program_counter_increment = next_instruction & increment;

  alu_instruction_decoder A(
    .instruction(current_instruction),
    .zeroflag(zeroflag),
    .signflag(signflag),
    .overflow(overflow),
    .errorbit(errorbit),
    .switches(switches),
    .program_counter_increment(increment),
    .alu_op(alu_op),
    .alu_a_altern(alu_a_altern),
    .alu_b_altern(alu_b_altern),
    .alu_a_select(alu_a_select),
    .alu_b_select(alu_b_select),
    .alu_a_source(alu_a_source),
    .alu_b_source(alu_b_source),
    .alu_out_select(alu_out_select),
    .alu_load_src(load_src),
    .alu_store_to_mem(alu_store_to_mem),
    .alu_store_to_stk(alu_store_to_stk)
    );

  localparam dvga = 4'h2;
  assign vga_color_select = current_instruction[7:4];
  assign vga_coord_select = current_instruction[3:0];
  assign vga_resetn = 1'b0;
  assign vga_plot = current_instruction[15:8] == {4'h0, dvga};

  localparam stopped = 3'b000, stopped_low = 3'b001, started = 3'b010,
    wait_read = 3'b011, wait_write = 3'b100, wait_buffer = 3'b101, wait_load = 3'b111;

  wire needs_read = load_src[1];
  wire needs_write = alu_store_to_stk | alu_store_to_mem;

  wire to_stopped = clock_lock  | (current_instruction == 16'h0300);
  assign switch_clock = to_stopped;

  reg[2:0] next_state;

  always @(*) begin: state_table
    case(current_state)
      stopped: next_state = user_clock ? stopped : stopped_low;
      stopped_low: next_state = user_clock ? started : stopped_low;
      started: begin
        if(needs_read) next_state = wait_read;
        else if(needs_write) next_state = wait_write;
        else next_state = wait_buffer;
      end
      wait_read: begin
        if(needs_write) next_state = wait_write;
        else next_state = wait_buffer;
      end
      wait_write: next_state = wait_buffer;
		wait_buffer: next_state = wait_load;
      wait_load: next_state = to_stopped ? stopped : started;
		default: next_state = stopped;
    endcase
  end

  always @(*) begin: enable_signals
    case(current_state)
      started: begin
        next_instruction = ~needs_read & ~needs_write;
        if(needs_read | needs_write) alu_load_src = 2'b00;
		  else alu_load_src = load_src;
      end
      wait_read: begin
        next_instruction = ~needs_write;
        if(needs_write) alu_load_src = 2'b00;
		    else alu_load_src = load_src;
      end
      wait_write: begin
        next_instruction = 1'b1;
		    alu_load_src = load_src;
      end
      default: begin
        next_instruction = 1'b0;
        alu_load_src = 2'b00;
      end
    endcase
  end

  always @(negedge clock) begin: state_FFs
    if(resetn) current_state <= next_state;
    else current_state <= stopped;
  end

endmodule
