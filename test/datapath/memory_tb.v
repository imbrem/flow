// This testbench exists mainly to test whether the mock memory module works as
// expected.

module memory_tb();

  reg clock;
  reg[15:0] program_counter;
  reg[15:0] address;
  reg[15:0] value;
  reg memory_store_enable;
  reg stack_store_enable;

  wire[15:0] current_instruction;
  wire[15:0] at_memory;
  wire[15:0] at_stack;

  memory M(clock, program_counter, address, value,
    memory_store_enable, stack_store_enable, current_instruction,
    at_memory, at_stack);

  always begin
    clock = 1'b0; #2; clock = 1'b1; #2;
  end

  initial begin

    $dumpfile("memory_tb.vcd");
    $dumpvars;

    program_counter = 16'hF;
    address = 16'hF;
    value = 16'hDFDF;
    memory_store_enable = 1'b1;
    stack_store_enable = 1'b1;
    #4;
    if(at_memory != 16'hDFDF)
      $display("Memory not stored: expected DFDF, got %h", at_memory);
    if(at_stack != 16'hDFDF)
      $display("Stack not stored: expected DFDF, got %h", at_stack);
    if(current_instruction != 16'hDFDF)
      $display("Program counter not updated: expected DFDF, got %h", current_instruction);

    address = 16'hE;
    value = 16'hDDDD;
    #4;
    if(at_memory != 16'hDDDD)
      $display("Memory not stored: expected DDDD, got %h", at_memory);
    if(at_stack != 16'hDDDD)
      $display("Stack not stored: expected DDDD, got %h", at_stack);
    if(current_instruction != 16'hDFDF)
      $display("Program counter changed: expected DFDF, got %h", current_instruction);

    address = 16'hF;
    value = 16'hAAAA;
    memory_store_enable = 1'b0;
    #4;
    if(at_memory != 16'hDFDF)
      $display("Memory not preserved: expected DFDF, got %h", at_memory);
    if(at_stack != 16'hAAAA)
      $display("Stack not stored: expected AAAA, got %h", at_stack);
    if(current_instruction != 16'hDFDF)
      $display("Program counter changed: expected DFDF, got %h", current_instruction);

    #4;

    $finish;
  end

endmodule
