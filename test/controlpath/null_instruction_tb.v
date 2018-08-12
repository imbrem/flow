module null_instruction_tb();

  reg[11:0] instruction;
  reg[15:0] switches;

  wire[54:0] control_word;
  wire program_counter_increment;
  wire[3:0] alu_op;
  wire[15:0] alu_a_altern;
  wire[15:0] alu_b_altern;
  wire[3:0] alu_a_select;
  wire[3:0] alu_b_select;
  wire alu_a_source;
  wire alu_b_source;
  wire[3:0] alu_out_select;
  wire[1:0] alu_load_src;
  wire alu_store_to_stk;
  wire alu_store_to_mem;

  wire[54:0] noop_control_word;

  localparam
    // Specials
    ujmp = 4'b0000, // Unconditional jump
    ldsw = 4'b0001, // Switch arithmetic to register
    dvga = 4'b0010, // Display VGA (color, coordinate) (not handled here)
    swcl = 4'b0011, // Switch clock (not handled here)

    // RESERVED

    // Loads
    rmem = 4'b1000, // Read memory to register
    wmem = 4'b1100, // Write register to memory
    rstk = 4'b1010, // Read stack to register
    wstk = 4'b1110, // Write register to stack
    rmof = 4'b1001, // Offset read memory to register
    wmof = 4'b1101, // Offset write register to memory
    rsof = 4'b1011, // Offset read stack to register
    wsof = 4'b1111; // Offset write stack to register

  alu_control_word_encoder noop_encoder(
        .program_counter_increment(1'b1),
        .alu_op(4'hx),
        .alu_a_altern(16'hxxxx),
        .alu_b_altern(16'hxxxx),
        .alu_a_select(4'hx),
        .alu_b_select(4'hx),
        .alu_a_source(1'bx),
        .alu_b_source(1'bx),
        .alu_out_select(4'hx),
        .alu_load_src(2'b00),
        .alu_store_to_mem(1'b0),
        .alu_store_to_stk(1'b0),
        .control_word(noop_control_word));

  alu_control_word_decoder D(
    .control_word(control_word),
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
    .alu_store_to_stk(alu_store_to_stk));

  null_instruction_decoder N(
    .instruction(instruction[11:0]),
    .switches(switches),
    .control_word(control_word));

  localparam
    inst_left = 4'h0,
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
    inst_itof = 4'hD,
    inst_utof = 4'hE,
    inst_ftoi = 4'hF;

  initial begin

    $dumpfile("null_instruction_tb.vcd");
    $dumpvars;

    switches = 16'h1242;

    // Ensure noop, dvga and swcl all generate noops
    instruction = {ujmp, 8'h0};
    #1 if(control_word != noop_control_word)
      $display("UJMP 0 0 (noop) does not generate ALU noop");
    instruction = {dvga, 8'h0};
    #1 if(control_word != noop_control_word)
      $display("DVGA 0 0 does not generate ALU noop");
    instruction = {swcl, 8'h0};
    #1 if(control_word != noop_control_word)
      $display("SWCL 0 0 does not generate ALU noop");

    // Check switch reading and ops happen correctly
    instruction = {ldsw, inst_left, 4'h5};
    #1 if(alu_op != inst_left) $display("LDSW LEFT 5 not passing LEFT to ALU");
    if(alu_b_select != 4'h5)
      $display("LDSW LEFT 5 generates incorrect selection for ALU B (expected 5, got %h)", alu_b_select);
    if(alu_a_altern != switches) $display("LDSW LEFT 5 generates incorrect altern for ALU A");
    if(alu_a_source != 1'b1) $display("LDSW LEFT 5 does not pass switches to ALU A");
    if(alu_b_source != 1'b0) $display("LDSW LEFT 5 does not pass register to ALU B");
    if(alu_out_select != 4'h5)
      $display("LDSW LEFT 5 generates incorrect selection for ALU C (expected 5, got %h)", alu_out_select);
    if(alu_load_src != 2'b01) $display("LDSW LEFT 5 has incorrect load mode (expected 01, got %b)", alu_load_src);
    if(alu_store_to_stk) $display("LDSW LEFT 5 stores to stack");
    if(alu_store_to_mem) $display("LDSW LEFT 5 stores to memory");

    instruction = {ldsw, inst_bxor, 4'h7};
    #1 if(alu_op != inst_bxor) $display("LDSW BXOR 7 not passing BXOR to ALU");
    if(alu_b_select != 4'h7)
      $display("LDSW BXOR 7 generates incorrect selection for ALU B (expected 7, got %h)", alu_b_select);
    if(alu_a_altern != switches) $display("LDSW BXOR 7 generates incorrect altern for ALU A");
    if(alu_a_source != 1'b1) $display("LDSW BXOR 7 does not pass switches to ALU A");
    if(alu_b_source != 1'b0) $display("LDSW BXOR 7 does not pass register to ALU B");
    if(alu_out_select != 4'h7)
      $display("LDSW BXOR 7 generates incorrect selection for ALU C (expected 7, got %h)", alu_out_select);
    if(alu_load_src != 2'b01) $display("LDSW BXOR 7 has incorrect load mode (expected 01, got %b)", alu_load_src);
    if(alu_store_to_stk) $display("LDSW BXOR 7 stores to stack");
    if(alu_store_to_mem) $display("LDSW BXOR 7 stores to memory");

    // Check memory reads and writes happen correctly
    instruction = {rmem, 4'h0, 4'h1};
    #1 if(alu_op != inst_left) $display("RMEM 0 1 not passing LEFT to ALU");
    if(alu_a_select != 4'h0)
      $display("RMEM 0 1 generates incorrect selection for ALU A (expected 0, got %h)", alu_a_select);
    if(alu_a_source != 4'b0)
      $display("RMEM 0 1 reading A from altern");
    if(alu_b_source != 4'b0)
      $display("RMEM 0 1 reading B from altern");
    if(alu_out_select != 4'h1)
      $display("RMEM 0 1 generates incorrect selection for ALU C (expected 1, got %h)", alu_out_select);
    if(alu_load_src != 2'b10) $display("RMEM 0 1 has incorrect load mode (expected 10, got %b)", alu_load_src);
    if(alu_store_to_stk) $display("RMEM 0 1 stores to stack");
    if(alu_store_to_mem) $display("RMEM 0 1 stores to memory");

    instruction = {rmof, 4'h0, 4'h1};
    #1 if(alu_op != inst_iadd) $display("RMOF 0 1 not passing IADD to ALU");
    if(alu_a_select != 4'h0)
      $display("RMOF 0 1 generates incorrect selection for ALU A (expected 0, got %h)", alu_a_select);
    if(alu_b_select != 4'h1)
      $display("RMOF 0 1 generates incorrect selection for ALU B (expected 1, got %h)", alu_b_select);
    if(alu_a_source != 4'b0)
      $display("RMOF 0 1 reading A from altern");
    if(alu_b_source != 4'b0)
      $display("RMOF 0 1 reading B from altern");
    if(alu_out_select != 4'h1)
      $display("RMOF 0 1 generates incorrect selection for ALU C (expected 1, got %h)", alu_out_select);
    if(alu_load_src != 2'b10) $display("RMOF 0 1 has incorrect load mode (expected 10, got %b)", alu_load_src);
    if(alu_store_to_stk) $display("RMOF 0 1 stores to stack");
    if(alu_store_to_mem) $display("RMOF 0 1 stores to memory");

    instruction = {wmem, 4'h0, 4'h1};
    #1 if(alu_op != inst_left) $display("WMEM 0 1 not passing LEFT to ALU");
    if(alu_a_select != 4'h1)
      $display("WMEM 0 1 generates incorrect selection for ALU A (expected 1, got %h)", alu_a_select);
    if(alu_a_source != 4'b0)
      $display("WMEM 0 1 reading A from altern");
    if(alu_b_source != 4'b0)
      $display("WMEM 0 1 reading B from altern");
    if(alu_out_select != 4'h0)
      $display("WMEM 0 1 generates incorrect selection for ALU C (expected 0, got %h)", alu_out_select);
    if(alu_load_src != 2'b00) $display("WMEM 0 1 has incorrect load mode (expected 00, got %b)", alu_load_src);
    if(alu_store_to_stk) $display("WMEM 0 1 stores to stack");
    if(~alu_store_to_mem) $display("WMEM 0 1 does not store to memory");

    instruction = {wmof, 4'h0, 4'h1};
    #1 if(alu_op != inst_iadd) $display("WMOF 0 1 not passing IADD to ALU");
    if(alu_a_select != 4'h1)
      $display("WMOF 0 1 generates incorrect selection for ALU A (expected 1, got %h)", alu_a_select);
    if(alu_b_select != 4'h0)
      $display("WMOF 0 1 generates incorrect selection for ALU B (expected 0, got %h)", alu_b_select);
    if(alu_a_source != 4'b0)
      $display("WMOF 0 1 reading A from altern");
    if(alu_b_source != 4'b0)
      $display("WMOF 0 1 reading B from altern");
    if(alu_out_select != 4'h0)
      $display("WMOF 0 1 generates incorrect selection for ALU C (expected 0, got %h)", alu_out_select);
    if(alu_load_src != 2'b00) $display("WMOF 0 1 has incorrect load mode (expected 00, got %b)", alu_load_src);
    if(alu_store_to_stk) $display("WMOF 0 1 stores to stack");
    if(~alu_store_to_mem) $display("WMOF 0 1 does not store to memory");


    // Check stack reads and writes happen correctly
    instruction = {rstk, 4'h0, 4'h1};
    #1 if(alu_op != inst_left) $display("RSTK 0 1 not passing LEFT to ALU");
    if(alu_a_select != 4'h0)
      $display("RSTK 0 1 generates incorrect selection for ALU A (expected 0, got %h)", alu_a_select);
    if(alu_a_source != 4'b0)
      $display("RSTK 0 1 reading A from altern");
    if(alu_b_source != 4'b0)
      $display("RSTK 0 1 reading B from altern");
    if(alu_out_select != 4'h1)
      $display("RSTK 0 1 generates incorrect selection for ALU C (expected 1, got %h)", alu_out_select);
    if(alu_load_src != 2'b11) $display("RSTK 0 1 has incorrect load mode (expected 11, got %b)", alu_load_src);
    if(alu_store_to_stk) $display("RSTK 0 1 stores to stack");
    if(alu_store_to_mem) $display("RSTK 0 1 stores to memory");

    instruction = {rsof, 4'h0, 4'h1};
    #1 if(alu_op != inst_iadd) $display("RSOF 0 1 not passing IADD to ALU");
    if(alu_a_select != 4'h0)
      $display("RSOF 0 1 generates incorrect selection for ALU A (expected 0, got %h)", alu_a_select);
    if(alu_b_select != 4'h1)
      $display("RSOF 0 1 generates incorrect selection for ALU B (expected 1, got %h)", alu_b_select);
    if(alu_a_source != 4'b0)
      $display("RSOF 0 1 reading A from altern");
    if(alu_b_source != 4'b0)
      $display("RSOF 0 1 reading B from altern");
    if(alu_out_select != 4'h1)
      $display("RSOF 0 1 generates incorrect selection for ALU C (expected 1, got %h)", alu_out_select);
    if(alu_load_src != 2'b11) $display("RSOF 0 1 has incorrect load mode (expected 11, got %b)", alu_load_src);
    if(alu_store_to_stk) $display("RSOF 0 1 stores to stack");
    if(alu_store_to_mem) $display("RSOF 0 1 stores to memory");

    instruction = {wstk, 4'h0, 4'h1};
    #1 if(alu_op != inst_left) $display("WSTK 0 1 not passing LEFT to ALU");
    if(alu_a_select != 4'h1)
      $display("WSTK 0 1 generates incorrect selection for ALU A (expected 1, got %h)", alu_a_select);
    if(alu_a_source != 4'b0)
      $display("WSTK 0 1 reading A from altern");
    if(alu_b_source != 4'b0)
      $display("WSTK 0 1 reading B from altern");
    if(alu_out_select != 4'h0)
      $display("WSTK 0 1 generates incorrect selection for ALU C (expected 0, got %h)", alu_out_select);
    if(alu_load_src != 2'b00) $display("WSTK 0 1 has incorrect load mode (expected 00, got %b)", alu_load_src);
    if(~alu_store_to_stk) $display("WSTK 0 1 does not store to stack");
    if(alu_store_to_mem) $display("WSTK 0 1 stores to memory");

    instruction = {wsof, 4'h0, 4'h1};
    #1 if(alu_op != inst_iadd) $display("WSOF 0 1 not passing IADD to ALU");
    if(alu_a_select != 4'h1)
      $display("WSOF 0 1 generates incorrect selection for ALU A (expected 1, got %h)", alu_a_select);
    if(alu_b_select != 4'h0)
      $display("WSOF 0 1 generates incorrect selection for ALU B (expected 0, got %h)", alu_b_select);
    if(alu_a_source != 4'b0)
      $display("WSOF 0 1 reading A from altern");
    if(alu_b_source != 4'b0)
      $display("WSOF 0 1 reading B from altern");
    if(alu_out_select != 4'h0)
      $display("WSOF 0 1 generates incorrect selection for ALU C (expected 0, got %h)", alu_out_select);
    if(alu_load_src != 2'b00) $display("WSOF 0 1 has incorrect load mode (expected 00, got %b)", alu_load_src);
    if(~alu_store_to_stk) $display("WSOF 0 1 does not store to stack");
    if(alu_store_to_mem) $display("WSOF 0 1 stores to memory");

    #1 $finish;

  end

endmodule
