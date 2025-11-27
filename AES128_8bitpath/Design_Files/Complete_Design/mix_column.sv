//--------------------------------------------------
// FILE NAME: mixcoloumn.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : mixcoloumn
//--------------------------------------------------
//PURPOSE : for mix coloumn opeation of the AES core
//--------------------------------------------------

module mix_column (  
                        data_in, 
                        enable, 
                        data_out0, 
                        data_out1, 
                        data_out2, 
                        data_out3, 
                        clk, 
                        rst
                    );

    input [7:0] data_in;
    input [7:0] enable;
    input clk; 
    input rst;

    output [7:0] data_out0;
    output [7:0] data_out1; 
    output [7:0] data_out2; 
    output [7:0] data_out3;
    
    
    logic [7:0] reg0; 
    logic [7:0] reg1; 
    logic [7:0] reg2; 
    logic [7:0] reg3;
    logic [7:0] data_in02; 
    logic [7:0] data_in03;
    
    assign data_in02 = { 
                            data_in[6:4], 
                            data_in[3] ^ data_in[7], 
                            data_in[2] ^ data_in[7], 
                            data_in[1], 
                            data_in[0] ^ data_in[7], 
                            data_in[7]
                        };
    assign data_in03 = {
                            data_in[7] ^ data_in[6], 
                            data_in[6] ^ data_in[5], 
                            data_in[5] ^ data_in[4], 
                            data_in[4] ^ data_in[3] ^ data_in[7], 
                            data_in[3] ^ data_in[2] ^ data_in[7] , 
                            data_in[2] ^ data_in[1], 
                            data_in[1] ^ data_in[0] ^ data_in[7], 
                            data_in[0] ^ data_in[7]
                        };

    always @ (posedge clk)
    if(rst) begin 
        reg0 <= '0;
        reg1 <= '0;
        reg2 <= '0;
        reg3 <= '0;
    end
    else begin
        reg0 <= data_in ^ (reg1 & enable);
        reg1 <= data_in ^ (reg2 & enable);
        reg2 <= data_in03 ^ (reg3 & enable);
        reg3 <= data_in02 ^ (reg0 & enable);
    end

    assign data_out0 = reg0;
    assign data_out1 = reg1;
    assign data_out2 = reg2;
    assign data_out3 = reg3;
endmodule
