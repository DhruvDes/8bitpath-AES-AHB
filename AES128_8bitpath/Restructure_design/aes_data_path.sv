//--------------------------------------------------
// FILE NAME: aes_data_path.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : Aes data path
//--------------------------------------------------
//PURPOSE : this is the control unit that controls the Aes data movement 
//--------------------------------------------------


module aes_data_path(
                        data_in, 
                        data_iout, 
                        pld, 
                        c3, 
                        clk, 
                        mix_column_en, 
                        round_key_delayedata_iout, 
                        round_key_last_out, 
                        rst
                    );

    input [7:0] data_in;
    output [7:0] data_iout;
    input pld;
    input [1:0] c3;
    input clk; 
    input rst;
    input [7:0] mix_column_en;
    input [7:0] round_key_delayedata_iout;
    input [7:0] round_key_last_out;
    
    logic [7:0] shift_row_in;
    logic [7:0] shift_row_out; 
    logic [7:0] sbox_out; 
    logic [7:0] mix_column_out0; 
    logic [7:0] mix_column_out1; 
    logic [7:0] mix_column_out2; 
    logic [7:0] mix_column_out3; 
    logic [7:0] sbox_o;
    logic [31:0] pdin;

    assign pdin = {
                     mix_column_out0, 
                     mix_column_out1, 
                     mix_column_out2, 
                     mix_column_out3
                  };

    assign sr_in = round_key_delayedata_iout ^ s_out;
    assign data_iout = sbox_o ^ round_key_last_out;

    shift_row_unit SR (
                           sr_in,  
                           sr_out, 
                           c3, 
                           clk, 
                           rst
                        );

    ps_conv PS (
                  data_in, 
                  s_out, 
                  pdin, 
                  pld, 
                  clk, 
                  rst
                );

    mix_column mix_column (
                       sbox_o, 
                       mix_column_en, 
                       mix_column_out0, 
                       mix_column_out1, 
                       mix_column_out2, 
                       mix_column_out3, 
                       clk, 
                       rst
                    );

    bSbox SB (
                sr_out, 
                sbox_o
             );

endmodule

