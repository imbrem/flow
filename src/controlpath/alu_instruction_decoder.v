module alu_instruction_decoder(
    input[15:0] instruction,
    input[15:0] zeroflag,
    input[15:0] signflag,
    input[15:0] overflow,
    input[15:0] errorbit,
    output program_counter_increment,
    output[3:0] alu_op,
    output[15:0] alu_a_altern,
    output[15:0] alu_b_altern,
    output[3:0] alu_a_select,
    output[3:0] alu_b_select,
    output alu_a_source,
    output alu_b_source,
    output[3:0] alu_load_src,
    output[1:0] alu_out_select,
    output alu_store_to_mem,
    output alu_store_to_stk);

endmodule
