module controlpath_tb();

  reg resetn;
  reg clock;
  reg user_clock;
  reg clock_lock;
  reg[15:0] current_instruction;
  reg[15:0] zeroflag;
  reg[15:0] signflag;
  reg[15:0] overflow;
  reg[15:0] errorbit;
  reg[15:0] switches;

  wire program_counter_increment;
  wire switch_clock;
  wire[3:0] alu_op;
  wire[15:0] alu_a_altern;
  wire[15:0] alu_b_altern;
  wire[3:0] alu_a_select;
  wire[3:0] alu_b_select;
  wire alu_a_source;
  wire alu_b_source;
  wire[3:0] alu_out_select;
  wire[1:0] alu_load_src;
  wire alu_store_to_mem;
  wire alu_store_to_stk;
  wire[3:0] vga_color_select;
  wire[3:0] vga_coord_select;
  wire vga_resetn;

  controlpath C(
    .resetn(resetn),
    .clock(clock),
    .user_clock(user_clock),
    .switch_clock(switch_clock),
    .clock_lock(clock_lock),
    .current_instruction(current_instruction),
    .switches(switches),
    .signflag(signflag),
    .zeroflag(zeroflag),
    .overflow(overflow),
    .errorbit(errorbit),
    .program_counter_increment(program_counter_increment),
    .alu_op(alu_op),
    .alu_a_altern(alu_a_altern),
    .alu_b_altern(alu_b_altern),
    .alu_a_select(alu_a_select),
    .alu_b_select(alu_b_select),
    .alu_a_source(alu_a_source),
    .alu_b_source(alu_b_source),
    .alu_out_select(alu_out_select),
    .alu_load_src(alu_load_src),
    .alu_store_to_mem(alu_store_to_mem),
    .alu_store_to_stk(alu_store_to_stk),
    .vga_color_select(vga_color_select),
    .vga_coord_select(vga_coord_select),
    .vga_plot(vga_plot),
    .vga_resetn(vga_resetn));

  always begin
    clock = 1'b0; #2; clock = 1'b1; #2;
  end

  localparam
    inst_null = 4'h0,
    inst_iadd = 4'h1,
    inst_isub = 4'h2,
    inst_imul = 4'h3,
    inst_idiv = 4'h4,
    inst_fadd = 4'h5,
    inst_fsub = 4'h6,
    inst_fmul = 4'h7,
    inst_fdiv = 4'h8,
    inst_band = 4'h9,
    inst_bior = 4'hA,
    inst_bxor = 4'hB,
    inst_ishl = 4'hC,
    inst_unar = 4'hD,
    inst_incr = 4'hE,
    inst_jump = 4'hF;

  initial begin

    $dumpfile("controlpath_tb.vcd");
    $dumpvars;

    // Reset controlpath
    resetn  = 1'b0;
    user_clock = 1'b1;
    clock_lock = 1'b0;
    current_instruction = 16'b0;
    zeroflag = 16'hFFFF;
    signflag = 16'b0;
    errorbit = 16'b0;
    switches = 16'b0;

    #6;

    // "Run" the program in loader.hex

    // Set current instruction to INCR 0 6 6
    resetn = 1'b1;
    current_instruction = {inst_incr, 4'h0, 4'h6, 4'h6};

    // Pulse user clock to start execution
    user_clock = 1'b0;
    #11;
    user_clock = 1'b1;

    #4 if(alu_op != inst_iadd)
      $display("INCR 0 6 6 does not generate IADD for ALU (generates %h)", alu_op);
    if(alu_out_select != 4'h6)
      $display("INCR 0 6 6 writes to incorrect register (expected 6, got %h)", alu_out_select);
    if(alu_load_src != 2'b01)
      $display("INCR 0 6 6 generates incorrect load mode (expected 01, got %b)", alu_load_src);
    if(alu_a_source)
      $display("INCR 0 6 6: ALU A loaded from altern (%h) instead of register", alu_a_altern);
    if(~alu_b_source)
      $display("INCR 0 6 6: ALU B loaded from register instead of altern (%h)", alu_b_altern);
    if(alu_b_altern != 4'h6)
      $display("INCR 0 6 6 has incorrect altern (got %h, expected 6)", alu_b_altern);
    if(alu_store_to_stk) $display("INCR 0 6 6 stores to stack");
    if(alu_store_to_mem) $display("INCR 0 6 6 stores to memory");

    // Appropriately set zeroflag
    zeroflag[6] = 1'b0;

    // Set current instruction to INCR 0 2 7
    current_instruction = {inst_incr, 4'h0, 4'h2, 4'h7};

    #4 if(alu_op != inst_iadd)
      $display("INCR 0 2 7 does not generate IADD for ALU (generates %h)", alu_op);
    if(alu_out_select != 4'h7)
      $display("INCR 0 2 7 writes to incorrect register (expected 7, got %h)", alu_out_select);
    if(alu_load_src != 2'b01)
      $display("INCR 0 2 7 generates incorrect load mode (expected 01, got %b)", alu_load_src);
    if(alu_a_source)
      $display("INCR 0 2 7: ALU A loaded from altern (%h) instead of register", alu_a_altern);
    if(~alu_b_source)
      $display("INCR 0 2 7: ALU B loaded from register instead of altern (%h)", alu_b_altern);
    if(alu_b_altern != 4'h2)
      $display("INCR 0 2 7 has incorrect altern (got %h, expected 2)", alu_b_altern);
    if(alu_store_to_stk) $display("INCR 0 2 7 stores to stack");
    if(alu_store_to_mem) $display("INCR 0 2 7 stores to memory");

    // Appropriately set zeroflag
    zeroflag[7] = 1'b0;

    // Set current instruction to NULL SWCL 0 0

    current_instruction = {inst_null, 4'h3, 4'h0, 4'h0};

    #4 if(alu_load_src != 2'b00)
      $display("Load on stopped clock (mode %b)", alu_load_src);
    if(alu_store_to_stk) $display("Store to stack on stopped clock");
    if(alu_store_to_mem) $display("Store to memory on stopped clock");

    #13;

    // Set switches while clock is stopped to, say, IADD 5 6 7
    switches = {inst_iadd, 4'h5, 4'h6, 4'h7};

    #11;

    // Update current instruction to NULL SWTR LEFT 5 while clock is stopped
    current_instruction = {inst_null, 4'h1, 4'h0, 4'h5};

    #4 if(alu_load_src != 2'b00)
      $display("Load on stopped clock (mode %b)", alu_load_src);
    if(alu_store_to_stk) $display("Store to stack on stopped clock");
    if(alu_store_to_mem) $display("Store to memory on stopped clock");

    // Pulse user clock to restart execution
    user_clock = 1'b0;
    #4 if(alu_load_src != 2'b00)
      $display("Load on stopped clock (mode %b)", alu_load_src);
    if(alu_store_to_stk) $display("Store to stack on stopped clock");
    if(alu_store_to_mem) $display("Store to memory on stopped clock");

    #21;

    user_clock = 1'b1;
    #4 if(alu_op != 4'h0)
      $display("NULL SWTR LEFT 5 does not generate LEFT for ALU (generates %h)", alu_op);
    if(alu_load_src != 2'b01)
      $display("NULL SWTR LEFT 5 generates incorrect load mode (expected 01, got %b)", alu_load_src);
    if(~alu_a_source)
      $display("NULL SWTR LEFT 5 not loading A from altern (%h)", alu_a_altern);
    if(alu_b_source)
      $display("NULL SWTR LEFT 5 loading B from altern (%h)", alu_b_altern);
    if(alu_b_select != 4'h5)
      $display("NULL SWTR LEFT 5 loading B from incorrect register (expected 5, got %h)", alu_b_select);
    if(alu_a_altern != switches)
      $display("NULL SWTR LEFT 5 loaded incorrect A altern (expected %h, got %h)", switches, alu_a_altern);
    if(alu_out_select != 4'h5)
      $display("NULL SWTR LEFT 5 selects incorrect output (expected 5, got %h)", alu_out_select);
    if(alu_store_to_stk) $display("NULL SWTR LEFT 5 stores to stack");
    if(alu_store_to_mem) $display("NULL SWTR LEFT 5 stores to memory");

    // Appropriately set zeroflag
    zeroflag[5] = 1'b0;

    // Update current instruction to INCR 0 1 6
    current_instruction = {inst_incr, 4'h0, 4'h1, 4'h6};

    #4 if(alu_op != inst_iadd)
      $display("INCR 0 1 6 does not generate IADD for ALU (generates %h)", alu_op);
    if(alu_out_select != 4'h6)
      $display("INCR 0 1 6 writes to incorrect register (expected 6, got %h)", alu_out_select);
    if(alu_load_src != 2'b01)
      $display("INCR 0 1 6 generates incorrect load mode (expected 01, got %b)", alu_load_src);
    if(alu_a_source)
      $display("INCR 0 1 6: ALU A loaded from altern (%h) instead of register", alu_a_altern);
    if(~alu_b_source)
      $display("INCR 0 1 6: ALU B loaded from register instead of altern (%h)", alu_b_altern);
    if(alu_b_altern != 4'h1)
      $display("INCR 0 1 6 has incorrect altern (got %h, expected 1)", alu_b_altern);
    if(alu_store_to_stk) $display("INCR 0 1 6 stores to stack");
    if(alu_store_to_mem) $display("INCR 0 1 6 stores to memory");

    // Update current instruction to NULL WMEM 5 6
    current_instruction = {inst_null, 4'b1100, 4'h5, 4'h6};
    #4 if(alu_op != 4'b0)
      $display("NULL WMEM 5 6 does not generate LEFT for ALU (generates %h)", alu_op);
    if(alu_out_select != 4'h5)
      $display("NULL WMEM 5 6 writes incorrect register (expected 5, got %h)", alu_out_select);
    if(alu_load_src != 2'b00)
      $display("NULL WMEM 5 6 generates incorrect load mode (expected 00, got %b)", alu_load_src);
    if(alu_a_source)
      $display("NULL WMEM 5 6: ALU A loaded from altern (%h) instead of register", alu_a_altern);
    if(alu_b_source)
      $display("NULL WMEM 5 6: ALU B loaded from altern (%h) instead of register", alu_b_altern);
    if(alu_store_to_stk) $display("NULL WMEM 5 6 stores to stack");
    if(~alu_store_to_mem) $display("NULL WMEM 5 6 does not store to memory");

    // Update current instruction to JUMP D-JNZ 5 7
    current_instruction  = {inst_jump, 2'b01, 2'b00, 4'h5, 4'h7};
    #4 if(alu_op != 4'b0)
      $display("JUMP D-JNZ 5 7 does not generate LEFT for ALU (generates %h)", alu_op);
    if(alu_out_select != 4'h0)
      $display("JUMP D-JNZ 5 7 writes to incorrect register (expected 0, got %h)", alu_out_select);
    if(alu_load_src != 2'b01)
      $display("JUMP D-JNZ 5 7 generates incorrect load mode (expected 01, got %b)", alu_load_src);
    if(alu_a_source)
      $display("JUMP D-JNZ 5 7: ALU A loaded from altern (%h) instead of register", alu_a_altern);
    if(alu_b_source)
      $display("JUMP D-JNZ 5 7: ALU B loaded from altern (%h) instead of register", alu_b_altern);
    if(alu_store_to_stk) $display("JUMP D-JNZ 5 7 stores to stack");
    if(alu_store_to_mem) $display("JUMP D-JNZ 5 7 stores to memory");

    // Set current instruction to NULL SWCL 0 0
    current_instruction = {inst_null, 4'h3, 4'h0, 4'h0};

    #4 if(alu_load_src != 2'b00)
      $display("Load on stopped clock (mode %b)", alu_load_src);
    if(alu_store_to_stk) $display("Store to stack on stopped clock");
    if(alu_store_to_mem) $display("Store to memory on stopped clock");

    #5;

    // Set switches while clock is stopped to NULL UJMP 0 0 (noop)
    switches = 16'h0;

    #27;

    // Update current instruction to NULL SWTR LEFT 5 while clock is stopped
    current_instruction = {inst_null, 4'h1, 4'h0, 4'h5};

    #4 if(alu_load_src != 2'b00)
      $display("Load on stopped clock (mode %b)", alu_load_src);
    if(alu_store_to_stk) $display("Store to stack on stopped clock");
    if(alu_store_to_mem) $display("Store to memory on stopped clock");

    // Pulse user clock to restart execution
    user_clock = 1'b0;
    #11 if(alu_load_src != 2'b00)
      $display("Load on stopped clock (mode %b)", alu_load_src);
    if(alu_store_to_stk) $display("Store to stack on stopped clock");
    if(alu_store_to_mem) $display("Store to memory on stopped clock");

    user_clock = 1'b1;
    #5 if(alu_op != 4'h0)
      $display("NULL SWTR LEFT 5 does not generate LEFT for ALU (generates %h)", alu_op);
    if(alu_load_src != 2'b01)
      $display("NULL SWTR LEFT 5 generates incorrect load mode (expected 01, got %b)", alu_load_src);
    if(~alu_a_source)
      $display("NULL SWTR LEFT 5 not loading A from altern (%h)", alu_a_altern);
    if(alu_b_source)
      $display("NULL SWTR LEFT 5 loading B from altern (%h)", alu_b_altern);
    if(alu_b_select != 4'h5)
      $display("NULL SWTR LEFT 5 loading B from incorrect register (expected 5, got %h)", alu_b_select);
    if(alu_a_altern != switches)
      $display("NULL SWTR LEFT 5 loaded incorrect A altern (expected %h, got %h)", switches, alu_a_altern);
    if(alu_out_select != 4'h5)
      $display("NULL SWTR LEFT 5 selects incorrect output (expected 5, got %h)", alu_out_select);
    if(alu_store_to_stk) $display("NULL SWTR LEFT 5 stores to stack");
    if(alu_store_to_mem) $display("NULL SWTR LEFT 5 stores to memory");

    // Appropriately set zeroflag
    zeroflag[5] = 1'b1;

    // Update current instruction to INCR 0 1 6
    current_instruction = {inst_incr, 4'h0, 4'h1, 4'h6};
    #4 if(alu_op != inst_iadd)
      $display("INCR 0 1 6 does not generate IADD for ALU (generates %h)", alu_op);
    if(alu_out_select != 4'h6)
      $display("INCR 0 1 6 writes to incorrect register (expected 6, got %h)", alu_out_select);
    if(alu_load_src != 2'b01)
      $display("INCR 0 1 6 generates incorrect load mode (expected 01, got %b)", alu_load_src);
    if(alu_a_source)
      $display("INCR 0 1 6: ALU A loaded from altern (%h) instead of register", alu_a_altern);
    if(~alu_b_source)
      $display("INCR 0 1 6: ALU B loaded from register instead of altern (%h)", alu_b_altern);
    if(alu_b_altern != 4'h1)
      $display("INCR 0 1 6 has incorrect altern (got %h, expected 1)", alu_b_altern);
    if(alu_store_to_stk) $display("INCR 0 1 6 stores to stack");
    if(alu_store_to_mem) $display("INCR 0 1 6 stores to memory");

    // Update current instruction to NULL WMEM 5 6
    current_instruction = {inst_null, 4'b1100, 4'h5, 4'h6};
    #4 if(alu_op != 4'b0)
      $display("NULL WMEM 5 6 does not generate LEFT for ALU (generates %h)", alu_op);
    if(alu_out_select != 4'h5)
      $display("NULL WMEM 5 6 writes incorrect register (expected 5, got %h)", alu_out_select);
    if(alu_load_src != 2'b00)
      $display("NULL WMEM 5 6 generates incorrect load mode (expected 00, got %b)", alu_load_src);
    if(alu_a_source)
      $display("NULL WMEM 5 6: ALU A loaded from altern (%h) instead of register", alu_a_altern);
    if(alu_b_source)
      $display("NULL WMEM 5 6: ALU B loaded from altern (%h) instead of register", alu_b_altern);
    if(alu_store_to_stk) $display("NULL WMEM 5 6 stores to stack");
    if(~alu_store_to_mem) $display("NULL WMEM 5 6 does not store to memory");

    // Update current instruction to JUMP D-JNZ 5 7
    current_instruction  = {inst_jump, 2'b01, 2'b00, 4'h5, 4'h7};
    #4 if(alu_op != 4'b0)
      $display("JUMP D-JNZ 5 7 does not generate LEFT for ALU (generates %h)", alu_op);
    if(alu_out_select != 4'h0)
      $display("JUMP D-JNZ 5 7 writes to incorrect register (expected 0, got %h)", alu_out_select);
    if(alu_load_src != 2'b00)
      $display("JUMP D-JNZ 5 7 generates incorrect load mode (expected 00, got %b)", alu_load_src);
    if(alu_a_source)
      $display("JUMP D-JNZ 5 7: ALU A loaded from altern (%h) instead of register", alu_a_altern);
    if(alu_b_source)
      $display("JUMP D-JNZ 5 7: ALU B loaded from altern (%h) instead of register", alu_b_altern);
    if(alu_store_to_stk) $display("JUMP D-JNZ 5 7 stores to stack");
    if(alu_store_to_mem) $display("JUMP D-JNZ 5 7 stores to memory");


    #1 $finish;

  end

endmodule
