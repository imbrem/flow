module memory(
  input clock,
  input[15:0] program_counter,
  input[15:0] address,
  input[15:0] value,
  input memory_store_enable,
  input stack_store_enable,
  output reg[15:0] current_instruction,
  output reg[15:0] at_memory,
  output reg[15:0] at_stack);

  `ifdef VERILATOR

  reg[65535:0] memory[15:0];
  reg[65535:0] stack[15:0];

  // Note the *blocking* assignment. This is intentional, as this component
  // is *not* meant for synthesis!
  always @(posedge clock) begin
    if(memory_store_enable) memory[address] = value;
    if(stack_store_enable) stack[address] = value;
    at_memory = memory[address];
    at_stack = stack[address];
    current_instruction = memory[program_counter];
  end

  `else

  

  `endif

endmodule
