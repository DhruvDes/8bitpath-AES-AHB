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
                        is_bist, 
                        rst, 
                        clk,
  	                    enable_lsfr_misr,
                        key_in,
                        data_in,
                        data_out,
                        output done_valid,
                        done
                     );
  
  
input is_bist;
input rst; 
input clk;
input enable_lsfr_misr; 
input  [7:0]key_in,;
input  [7:0]data_in;
output [7:0] data_out;
output done_valid;
output done;  
  
  
  
  
logic [7:0] key_input_bist, 
logic [7:0] data_input_bist;
logic [7:0] mux_to_key, 
logic [7:0] mux_to_data, 
logic [7:0] misr_to_data_out, 
logic [7:0] device_to_data_out;
  
  
  
  lfsr #(
      .WIDTH(8),
      .TAPS(8'b0110_0011), 
      .SEED(8'hA5)
  ) lsfr_aes_key (
      .clk(clk),
      .rst(rst),
      .en(en_lsfr_misr),
    .q(key_input_bist)
  );
  
    lfsr #(
      .WIDTH(8),
      .TAPS(8'b0110_0011), 
      .SEED(8'h0f)
    ) lsfr_aes_data (
      .clk(clk),
      .rst(rst),
      .en(en_lsfr_misr),
      .q(data_input_bist)
  );
 
  assign mux_to_key = is_bist ?  key_input_bist : key_in;
  assign mux_to_data = is_bist ?  data_input_bist : data_in;
  
  aes_8_bit ins1 (.rst(rst), 
                  .clk(clk), 
                  .key_in(mux_to_key), 
                  .data_in(mux_to_data), 
                  .data_out(device_to_data_out), 
                  .data_valid(done_valid),
                 
                  .done(done));
  

  
  misr misr_aes (
    .clk(clk),
    .rst(rst),
    .enable(enable_lsfr_misr),
    .data_in(device_to_data_out),
    .sig(misr_to_data_out)
  
  );
  
  
  assign d_out = is_bist ? misr_to_data_out : device_to_data_out;
  
  
  // output for ROM is 0xC0;
  
  
  
  

endmodule


interface aes_bist_if;
 logic rst, clk, d_vld, DONE, is_bist, en_lsfr_misr;
  logic[7:0] key_in, d_in, d_out; 
endinterface

