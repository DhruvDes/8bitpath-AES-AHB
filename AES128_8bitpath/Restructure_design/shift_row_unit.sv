//--------------------------------------------------
// FILE NAME: byte_permutation_unit.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : shift row
//--------------------------------------------------
//PURPOSE : reordering the bytes
//--------------------------------------------------

module byte_permutation (
                          data_in, 
                          data_out, 
                          c3, 
                          clk, 
                          rst
                        );

    input [7:0] data_in;
    output [7:0] data_out;
    input [1:0] c3;
    input clk; 
    input rst;

    logic c0;
    logic c1; 
    logic c2;
    logic [7:0] mux0_o; 
    logic [7:0] mux1_o; 
    logic [7:0] mux2_o;
    logic [7:0] register_12; 
    logic [7:0] register_11; 
    logic [7:0] register_10; 
    logic [7:0] register_9; 
    logic [7:0] register_8; 
    logic [7:0] register_7; 
    logic [7:0] register_6; 
    logic [7:0] register_5; 
    logic [7:0] register_4; 
    logic [7:0] register_3; 
    logic [7:0] register_2; 
    logic [7:0] register_1;

    assign c0 = ~ (c3[1] | c3[0]);
    assign c1 = ~ (c3[1] | (~ c3[0])); 
    assign c2 = ~ ((~ c3[1]) | c3[0]);

    mux2_1 mux0 (
                  register_1, 
                  data_in, 
                  mux0_o, 
                  c0
                );

    mux2_1 mux1 (
                  register_1, 
                  register_9, 
                  mux1_o, 
                  c1
                );

    mux2_1 mux2 (
                  register_1, 
                  register_5, 
                  mux2_o, 
                  c2
                );

    mux4_1 mux3 (
                  data_in, 
                  register_9, 
                  register_5, 
                  register_1, 
                  data_out, 
                  c3
                );

    always @ (posedge clk)
    if(rst)begin 
        register_12 <= '0;
        register_11 <= '0;
        register_10 <= '0;
        register_9  <= '0;
        register_8  <= '0;
        register_7  <= '0;
        register_6  <= '0;
        register_5  <= '0;
        register_4  <= '0;
        register_3  <= '0;
        register_2  <= '0;
        register_1  <= '0;

    end
    else begin
        register_12 <= mux0_o;
        register_11 <= register_12;
        register_10 <= register_11;
        register_9  <= register_10;
        register_8  <= mux1_o;
        register_7  <= register_8;
        register_6  <= register_7;
        register_5  <= register_6;
        register_4  <= mux2_o;
        register_3  <= register_4;
        register_2  <= register_3;
        register_1  <= register_2;
    end
endmodule
        
