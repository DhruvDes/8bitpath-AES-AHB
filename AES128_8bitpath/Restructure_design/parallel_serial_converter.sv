--------------------------------------------------
// FILE NAME: parallel_serial_converter.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : parallel to serial convertor
//--------------------------------------------------
//PURPOSE : convert the parllel data to serial data 
//--------------------------------------------------

module parallel_serial_converter(
                  data_in, 
                  data_out, 
                  parallel_data_in, 
                  parallel_load, 
                  clk, 
                  rst
               );
    
    input [7:0] data_in;            // input data
    output [7:0] data_out;          // output data
    input [31:0] parallel_data_in;  // highest byte go out first
    input parallel_load;            // 1 used for parallel load, 0 used for serial unload
    input clk; 
    input rst;

    logic [7:0] register1;
    logic [7:0] register2;
    logic [7:0] register3;
    logic [7:0] register4;

    logic [7:0] mux1_o;
    logic [7:0] mux2_o; 
    logic [7:0] mux3_o;

    mux2_1 mux0 (
                    parallel_data_in[31:24],
                    register0, 
                    Data_out, 
                    parallel_load
                 );

    mux2_1 mux1 (
                    parallel_data_in[23:16], 
                    register1, 
                    mux1_o, 
                    parallel_load
                );

    mux2_1 mux2 (
                    parallel_data_in[15: 8], 
                    register2, 
                    mux2_o, 
                    parallel_load
                );

    mux2_1 mux3 (
                    parallel_data_in[ 7: 0],
                    register3, 
                    mux3_o, 
                    parallel_load
                );

    always @ (posedge clk)
    if(rst)begin 
        register3 <= '0;
        register2 <= '0;
        register1 <= '0;
        register0 <= '0;
    end
    else begin
        register3 <= Data_in;
        register2 <= mux3_o;
        register1 <= mux2_o;
        register0 <= mux1_o;
    end
endmodule
        
