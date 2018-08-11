module alu_tb();

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

  reg[3:0] op;
  reg[15:0] a;
  reg[15:0] b;
  wire[15:0] c;
  wire o;
  wire e;

  ALU A(
    .alu_op(op),
    .a(a),
    .b(b),
    .c(c),
    .ofl(o),
    .err(e));

  initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars;

    // Test inst_left
    op = inst_left;
    a = 16'hA;
    b = 16'hF;
    #1 if(c != a) $display("ERROR: (%h) %h %h = A (got %h)", op, a, b, c);
    a = 16'hE;
    b = 16'hD;
    #1 if(c != a) $display("ERROR: (%h) %h %h = E (got %h)", op, a, b, c);
    // Test inst_iadd
    op = inst_iadd;
    a = 16'h1;
    b = 16'h1;
    #1 if(c != 16'h2) $display("ERROR: (%h) %h %h = 2 (got %h)", op, a, b, c);
    a = 16'hF;
    b = 16'hFF;
    #1 if(c != 16'h10E) $display("ERROR: (%h) %h %h = 10E (got %h)", op, a, b, c);
    // Test inst_isub
    op = inst_isub;
    a = 16'h1;
    b = 16'h1;
    #1 if(c != 16'h0) $display("ERROR: (%h) %h %h = 0 (got %h)", op, a, b, c);
    a = 16'hF;
    b = 16'hFF;
    #1 if(c != -16'hF0) $display("ERROR: (%h) %h %h = -F0 (got %h)", op, a, b, c);
    // Test inst_imul
    op = inst_imul;
    a = 16'h1;
    b = 16'h7;
    #1 if(c != 16'h7) $display("ERROR: (%h) %h %h = 7 (got %h)", op, a, b, c);
    a = 16'hF;
    b = 16'hFF;
    #1 if(c != 16'hEF1) $display("ERROR: (%h) %h %h = EF1 (got %h)", op, a, b, c);
    // Test inst_idiv
    op = inst_idiv;
    a = 16'h14;
    b = 16'h7;
    #1 if(c != 16'h2) $display("ERROR: (%h) %h %h = 2 (got %h)", op, a, b, c);
    a = 16'h1;
    b = 16'h0;
    #1 if(!e) $display("ERROR: error bit not set in (integer) division by 0");
    // Test inst_fadd
    op = inst_fadd;
    a = 16'h3C00;
    b = 16'h3C00 ^ 16'h8000;
    #1 if(c != 16'h0) $display("ERROR: (%h) %h %h = 0 [0.0f] (got %h)", op, a, b, c);
    a = 16'h4000;
    b = 16'h3C00;
    #1 if(c != -16'h4200) $display("ERROR: (%h) %h %h = 4200 [3.0f] (got %h)", op, a, b, c);
    // Test inst_fsub
    op = inst_fsub;
    a = 16'h3C00;
    b = 16'h4000;
    #1 if(c != 16'hBC00) $display("ERROR: (%h) %h %h = BC00 [-1.0f] (got %h)", op, a, b, c);
    a = 16'h4000;
    b = 16'h4000;
    #1 if(c != -16'h0) $display("ERROR: (%h) %h %h = 0 [0.0f] (got %h)", op, a, b, c);
    // Test inst_fmul
    op = inst_fmul;
    a = 16'h3C00;
    b = 16'h4000;
    #1 if(c != 16'h4000) $display("ERROR: (%h) %h %h = 4000 [2.0f] (got %h)", op, a, b, c);
    a = 16'h4000;
    b = 16'h4000;
    #1 if(c != -16'h4400) $display("ERROR: (%h) %h %h = 4400 [4.0f] (got %h)", op, a, b, c);
    // Test inst_fdiv
    op = inst_fdiv;
    a = 16'h4400;
    b = 16'h4000;
    #1 if(c != 16'h4000) $display("ERROR: (%h) %h %h = 4000 [2.0f] (got %h)", op, a, b, c);
    a = 16'h4000;
    b = 16'h0000;
    #1 if(!e) $display("ERROR: error bit not set in (floating) division by 0");
    // Test inst_band
    op = inst_band;
    a = 16'b0101010101010101;
    b = 16'b0000111100001111;
    #1 if(c != 16'b0000010100000101) $display("ERROR: (%h) %b %b = 0000010100000101 (got %b)", op, a, b, c);
    // Test inst_bior
    op = inst_bior;
    #1 if(c != 16'b0101111101011111) $display("ERROR: (%h) %b %b = 0101111101011111 (got %b)", op, a, b, c);
    // Test inst_bxor
    op = inst_bxor;
    #1 if(c != 16'b0101101001011010) $display("ERROR: (%h) %b %b = 0101101001011010 (got %b)", op, a, b, c);
    // Test inst_ishl
    op = inst_ishl;
    a = 16'h8000;
    b = 16'h1;
    #1 if(c != 16'h0) $display("ERROR: (%h) %h %h = 0 (got %h)", op, a, b, c);
    a = 16'h8000;
    b = -16'h1;
    #1 if(c != 16'h4000) $display("ERROR: (%h) %h %h = 4000 (got %h)", op, a, b, c);
    //TODO:
    // Test inst_itof
    // Test inst_utof
    // Test inst_ftoi
    #1;
    $finish;
  end

endmodule
