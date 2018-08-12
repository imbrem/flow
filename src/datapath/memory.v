module memory(
  input clock,
  input[15:0] program_counter,
  input[15:0] address,
  input[15:0] value,
  input memory_store_enable,
  input stack_store_enable,
  output[15:0] current_instruction,
  output[15:0] at_memory,
  output[15:0] at_stack);

  `ifdef VERILATOR
    `define mock_memory
  `endif

  `ifdef __ICARUS__
    `define mock_memory
  `endif

  `ifdef mock_memory

  reg[65535:0] memory[15:0];
  reg[65535:0] stack[15:0];

  reg[15:0] reg_at_memory;
  reg[15:0] reg_at_stack;
  reg[15:0] reg_current_instruction;

  assign at_memory = reg_at_memory;
  assign at_stack = reg_at_stack;
  assign current_instruction = reg_current_instruction;

  `ifdef FLOW_MEMORY_INITIALIZER
  initial begin
    `FLOW_MEMORY_INITIALIZER
  end
  `endif

  // Note the *blocking* assignment. This is intentional, as this component
  // is *not* meant for synthesis!
  always @(posedge clock) begin
    if(memory_store_enable) memory[address] = value;
    if(stack_store_enable) stack[address] = value;
    reg_at_memory = memory[address];
    reg_at_stack = stack[address];
    reg_current_instruction = memory[program_counter];
  end

  `else

  stack_ram stack(
    .address(address),
    .clock(clock),
    .data(value),
    .wren(stack_store_enable),
    .q(at_stack));

  memory_ram memory(
    .address_a(program_counter),
    .address_b(address),
    .clock(clock),
    .data_a(16'hxxxx),
    .data_b(value),
    .wren_a(1'b0),
    .wren_b(memory_store_enable),
    .q_a(current_instruction),
    .q_b(at_memory));

  `endif

endmodule
