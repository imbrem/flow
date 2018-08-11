module flag_tb();

  reg[255:0] registers;
  wire[15:0] signflag;
  wire[15:0] zeroflag;

  zeroflag_generator Z(registers, zeroflag);
  signflag_generator S(registers, signflag);

  initial begin

    $dumpfile("flag_tb.vcd");
    $dumpvars;

    registers = 256'b0;
    #1 if(zeroflag != 16'hFFFF)
      $display("Zeroflag not computed correctly (expected 1111111111111111, got %b)", zeroflag);
    if(signflag != 16'h0)
      $display("Signflag not computed correctly (expected 0000000000000000, got %b)", signflag);
    registers = {240'b0, 16'hC};
    #1 if(zeroflag != 16'hFFFE)
      $display("Zeroflag not computed correctly (expected 1111111111111110, got %b)", zeroflag);
    if(signflag != 16'h0)
      $display("Signflag not computed correctly (expected 0000000000000000, got %b)", signflag);
    registers = {224'b0, 16'h8000, 16'hC};
    #1 if(zeroflag != 16'hFFFC)
      $display("Zeroflag not computed correctly (expected 1111111111111100, got %b)", zeroflag);
    if(signflag != 16'h0002)
      $display("Signflag not computed correctly (expected 0000000000000010, got %b)", signflag);

    #1 $finish;

  end

endmodule
