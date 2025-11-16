// `include "lsfr_misr.sv"
// `include "aes_top.sv"


// module aes_8_bit (rst, clk, key_in, d_in, d_out, d_vld, DONE);
//     input rst, clk;
//     input [7:0] key_in;
//     input [7:0] d_in;
//     output [7:0] d_out;
//     output reg d_vld;
//   	output logic DONE;


//     input  logic clk,
//     input  logic rst,
//     input  logic en,
//     input  logic [WIDTH-1:0] data_in,   // DUT outputs (8-bit)
//     output logic [WIDTH-1:0] sig        // running signature

module aes_top_bist(
  input   is_bist, 
              rst, 
              clk,
  	 en_lsfr_misr,
  
  input [7:0]key_in,
   input [7:0]d_in,
  
  output [7:0] d_out,
  output d_vld, DONE
  

);
  
  logic [7:0] key_input_bist, data_input_bist;
  logic [7:0] mux_to_key, mux_to_data, misr_to_data_out, device_to_data_out;
  
  
  
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
  assign mux_to_data = is_bist ?  data_input_bist : d_in;
  
  aes_8_bit ins1 (.rst(rst), 
                  .clk(clk), 
                  .key_in(mux_to_key), 
                  .d_in(mux_to_data), 
                  .d_out(device_to_data_out), 
                  .d_vld(d_vld),
                 
                  .DONE(DONE));
  

  
  misr misr_aes (
    .clk(clk),
    .rst(rst),
    .en(en_lsfr_misr),
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

