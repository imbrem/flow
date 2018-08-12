module fpga_loader_tb();

  // Simple loader program:
  // INCR 2 7
  // INCR 6 6
  // SWCL
  // SWTR LEFT 5
  // INCR 1 6
  // WMEM 5 6
  // D-JNZ 5 7
  `define FLOW_MEMORY_INITIALIZER \
    memory[0] = 16'hE027;\
    memory[1] = 16'hE066;\
    memory[2] = 16'h0300;\
    memory[3] = 16'h0105;\
    memory[4] = 16'hE016;\
    memory[5] = 16'h0C56;\
    memory[6] = 16'hF457;

  `define FLOW_NICER_REGISTER_VIEW

  `include "../test/fpga_top/fpga_top_tb.hv"


  initial begin

    $dumpfile("fpga_loader_tb.vcd");
    $dumpvars;

    // Wait a while before initializing everything, set the offset/clock lock, reset registers

    KEY[0] = 1'b0;
    KEY[1] = 1'b1;
    KEY[2] = 1'b1;
    KEY[3] = 1'b1;
    SW = 10'b1000010001; // Special mode, clock lock off, offset 0x11 (instruction)

    #13;

    KEY[0] = 1'b1; // Turn reset off

    #31;

    // Begin by pulsing user clock

    KEY[2] = 1'b0;

    #41;

    KEY[2] = 1'b1;

    // Wait a while for interrupt
    #100;

    // Set switch register to 3 5 5 5 (IMUL 5 5 5)
    SW = {2'b01, 4'h3, 4'h5};
    KEY[1] = 1'b0;
    #24;
    KEY[1] = 1'b1;
    #13;
    SW = {2'b00, 4'h5, 4'h5};
    #23;
    KEY[1] = 1'b0;
    #22;

    // Pulse user clock again

    KEY[2] = 1'b0;

    #23;

    KEY[2] = 1'b1;

    #11;

    // And wait...

    #52;

    // Set switch register to 1 5 6 7 (IADD 5 6 7)
    SW = {2'b01, 4'h1, 4'h5};
    KEY[1] = 1'b0;
    #21;
    KEY[1] = 1'b1;
    #11;
    SW = {2'b00, 4'h6, 4'h7};
    #21;
    KEY[1] = 1'b0;
    #25;

    // Pulse user clock again

    KEY[2] = 1'b0;

    #20;

    KEY[2] = 1'b1;

    #5;

    // And wait...

    #64;


    // Set switch register to 0 0 0 0 (NOOP)
    SW = {2'b01, 4'h0, 4'h0};
    KEY[1] = 1'b0;
    #10;
    KEY[1] = 1'b1;
    #5;
    SW = {2'b00, 4'h0, 4'h0};
    #31;
    KEY[1] = 1'b0;
    #20;

    // Pulse user clock again

    KEY[2] = 1'b0;

    #10;

    KEY[2] = 1'b1;

    #6;

    // And wait...

    #100;

    #16 $finish;

  end

endmodule
