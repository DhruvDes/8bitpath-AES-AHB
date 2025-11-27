//--------------------------------------------------
// FILE NAME: key_expansion.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : key expansion
//--------------------------------------------------
//PURPOSE : used for expanding key 
//--------------------------------------------------

module key_expansion(
                       key_in, 
                       round_key_delayed_out, 
                       round_count, 
                       round_key_last_out, 
                       clk, 
                       input_sel, 
                       sbox_sel, 
                       last_out_sel, 
                       bit_out_sel, 
                       round_con_enable, 
                       rst
                    );

    input [7:0] key_in;
    output [7:0] round_key_delayed_out;
    output [7:0] round_key_last_out;
    input [3:0] round_count;
    input clk; 
    input rst;
    input input_sel;
    input sbox_sel;
    input last_out_sel;
    input bit_out_sel; 
    input [7:0] round_con_enable;

    logic [7:0] r15;
    logic [7:0] r14;
    logic [7:0] r13;
    logic [7:0] r12;
    logic [7:0] r11;
    logic [7:0] r10;
    logic [7:0] r9;
    logic [7:0] r8;
    logic [7:0] r7;
    logic [7:0] r6;
    logic [7:0] r5;
    logic [7:0] r4;
    logic [7:0] r3;
    logic [7:0] r2;
    logic [7:0] r1;
    logic [7:0] r0;
    logic [7:0] r_redun;

    logic [7:0] round_con_sbox_o;
    logic [7:0] sbox_o;
    logic [7:0] round_con_o;
    logic [7:0] sbox_in;
    logic [7:0] mux_in_o;
    logic [7:0] mux_bit_o;
    logic [7:0] round_con_num;
    
    function [7:0] round_con;
      input [3:0] x;
        casex (x)
          4'b0000: round_con = 8'h01;
          4'b0001: round_con = 8'h02;
          4'b0010: round_con = 8'h04;
          4'b0011: round_con = 8'h08;
          4'b0100: round_con = 8'h10;
          4'b0101: round_con = 8'h20;
          4'b0110: round_con = 8'h40;
          4'b0111: round_con = 8'h80;
          4'b1000: round_con = 8'h1b;
          4'b1001: round_con = 8'h36;
          default: round_con = 8'h01;
        endcase
    endfunction

    assign round_con_num = round_con(round_count);


    assign round_con_sbox_o = sbox_o ^ round_con_o;
    assign round_con_o = round_con_enable & round_con_num;
    assign round_key_delayed_out = r12;
    

    mux2_1 mux_in (
                      round_key_last_out, 
                      key_in, 
                      mux_in_o, 
                      input_sel
                    );

    mux2_1 mux_sbox (
                            r13, 
                            r_redun, 
                            sbox_in, 
                            sbox_sel
                    ); 

    mux2_1 mux_bit (
                            (r4 ^ round_key_last_out), 
                            r4, 
                            mux_bit_o, 
                            bit_out_sel
                    );

    mux2_1 mux_last_out (
                            r0, 
                            (r0 ^ round_con_sbox_o),
                            round_key_last_out, 
                            last_out_sel
                        );

    bSbox sbox (
                            sbox_in,
                            sbox_o
                );



    always @ (posedge clk)
    if (rst) begin 
        r15 <= '0; 
        r14 <= '0;
        r13 <= '0;
        r12 <= '0;
        r11 <= '0;
        r10 <= '0;
        r9  <= '0;
        r8  <= '0;
        r7  <= '0;
        r6  <= '0;
        r5  <= '0;
        r4  <= '0;
        r3  <= '0;
        r2  <= '0;
        r1  <= '0;
        r0  <= '0;
    end
    else begin
        r15 <= mux_in_o;
        r14 <= r15;
        r13 <= r14;
        r12 <= r13;
        r11 <= r12;
        r10 <= r11;
        r9  <=  r10;
        r8  <=  r9;
        r7  <=  r8;
        r6  <=  r7;
        r5  <=  r6;
        r4  <=  r5;
        r3  <=  mux_bit_o;
        r2  <=  r3;
        r1  <=  r2;
        r0  <=  r1;
    end
    
    always @ (posedge clk)
    begin
        if (rst) begin 
            r_redun <= '0;
        end
        if (round_con_enable == 8'hff)
        begin
            r_redun <= r12;
        end
    end 
endmodule
