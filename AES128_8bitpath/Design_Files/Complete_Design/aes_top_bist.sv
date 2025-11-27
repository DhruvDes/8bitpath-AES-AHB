`include "lfsr.sv"
`include "misr.sv"

//--------------------------------------------------
// FILE NAME: aes_top_bist.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : key expansion
//--------------------------------------------------
//PURPOSE : top module including bist 
 
module aes_top_bist(
                        clk,
                        rst, 
  	                    enable_lsfr_misr,
                        key_in,
                        data_in,
                        data_out,
                        d_out
                     );
  
  
input rst; 
input clk;
input enable_lsfr_misr; 
output  [7:0]key_in;
output  [7:0]data_in;
input [7:0] data_out;
  output logic [7:0] d_out;
  
  
  
  
  logic [7:0] key_input_bist; 
logic [7:0] data_input_bist;
  logic [7:0] misr_to_data_out; 

  
  
  lfsr #(
      .WIDTH(8),
      .TAPS(8'b0110_0011), 
      .SEED(8'hA5)
  ) lsfr_aes_key (
      .clk(clk),
      .rst(rst),
      .enable(enable_lsfr_misr),
    .q(key_input_bist)
  );
  
    lfsr #(
      .WIDTH(8),
      .TAPS(8'b0110_0011), 
      .SEED(8'h0f)
    ) lsfr_aes_data (
      .clk(clk),
      .rst(rst),
      .enable(enable_lsfr_misr),
      .q(data_input_bist)
  );
 
  assign key_in = key_input_bist;
  assign data_in = data_input_bist;
  
  
  misr misr_aes (
    .clk(clk),
    .rst(rst),
    .enable(enable_lsfr_misr),
    .data_in(data_out),
    .signal(misr_to_data_out)
  
  );
  
  
  assign d_out = misr_to_data_out;
  
  
  // output for ROM is 0xC0;

endmodule