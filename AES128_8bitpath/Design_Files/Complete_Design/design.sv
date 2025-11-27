`include "ahb_top.sv"
`include "aes_top.sv"
`include "bist_ctrl.sv"
`include "aes_top_bist.sv"

module ip_top(

	input  logic        HCLK,
    input  logic        HRESETn,

    input  logic        HSEL,
    input  logic [31:0] HADDR,
    input  logic [1:0]  HTRANS,
    input  logic        HWRITE,
    input  logic [2:0]  HSIZE,
    input  logic [31:0] HWDATA,
    input  logic        HREADY,
  	input logic [2:0] HBURST,

    output logic [31:0] HRDATA,
    output logic        HREADYOUT,
  	output logic        HRESP
);
  
  wire [7:0] ahb_key_in;
  wire [7:0] ahb_d_in;
  
  wire [7:0] ahb_d_out;
  wire [7:0] bist_dout;
  
  wire [7:0] bist_key_in;
  wire [7:0] bist_d_in;
  wire [7:0] d_out;
  wire aes_rst;
  wire aes_core_rst;
  //wire rst;
  wire d_vld;
  wire DONE;
  
  wire [7:0] aes_key_in;
  wire [7:0] aes_d_in;
  
  wire is_bist;
  logic bist_rst_int;
  logic en_lsfr_misr_int; 
  
  assign aes_key_in = is_bist ?  bist_key_in : ahb_key_in;
  assign aes_d_in = is_bist ?  bist_d_in : ahb_d_in;
  assign ahb_d_out = is_bist ? bist_dout : d_out;
  assign aes_core_rst = (~HRESETn) | aes_rst;
  
  ahb_top ahb(.HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL), .HADDR(HADDR), .HTRANS(HTRANS), .HWRITE(HWRITE), .HSIZE(HSIZE), .HBURST(HBURST), .HWDATA(HWDATA), .HREADY(HREADY), .HRDATA(HRDATA), .HREADYOUT(HREADYOUT), .HRESP(HRESP), .aes_rst(aes_rst), .aes_key_in(ahb_key_in), .aes_din(ahb_d_in), .aes_dout(ahb_d_out), .aes_valid(d_vld), .aes_done_in(DONE), .is_bist(is_bist));
  
  bist_ctrl u_bist_ctrl (.clk(HCLK), .rst_n (HRESETn), .is_bist (is_bist), .bist_rst (bist_rst_int), .en_lsfr_misr(en_lsfr_misr_int));

  
  aes_top_bist bist(.clk(HCLK), .rst(bist_rst_int), .enable_lsfr_misr(en_lsfr_misr_int), .key_in(bist_key_in), .data_in(bist_d_in), .data_out(d_out), .d_out(bist_dout));
  
  
  
  aes_top aes(.rst(aes_core_rst), .clk(HCLK), .key_in(aes_key_in), .data_in(aes_d_in), .data_out(d_out), .data_valid(d_vld), .done(DONE));
  
endmodule