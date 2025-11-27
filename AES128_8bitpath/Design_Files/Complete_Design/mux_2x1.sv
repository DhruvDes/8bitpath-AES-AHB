--------------------------------------------------
// FILE NAME: mux_2x1.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : 2x1 multiplier 
//--------------------------------------------------
//PURPOSE : selecting the data form 2 lines  
//--------------------------------------------------

module mux2_1(
                mux_in1, 
                mux_in2, 
                Out, 
                sel
             );

    input [7:0] mux_in1; 
    input [7:0]mux_in2;
    output [7:0] Out;
    input sel;

    assign Out = sel ? mux_in1 : mux_in2;
endmodule



