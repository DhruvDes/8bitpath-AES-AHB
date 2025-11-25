// FILE NAME: mux_4x1.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : 4x1 multiplier 
//--------------------------------------------------
//PURPOSE : selecting the data from 4 lines 
//--------------------------------------------------

module mux4_1(
                mux_in1,
                mux_in2, 
                mux_in3, 
                mux_in4, 
                out, 
                sel
              );

    input [7:0] mux_in1; 
    input [7:0] mux_in2; 
    input [7:0] mux_in3;
    input [7:0] mux_in4;
    output [7:0] out;
    input [1:0] sel;

    logic [7:0] temp_out_reg;
    assign out = temp_out_reg;

    always@(*)
    begin
        case(sel)
            2'b00: temp_out_reg = mux_in1;
            2'b01: temp_out_reg = mux_in2;
            2'b10: temp_out_reg = mux_in3;
            default: temp_out_reg = mux_in4;
        endcase
    end
endmodule