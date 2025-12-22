module data_path_one ( 
  	input [7:0] d_in, 
    output [7:0] d_out, 
    input pld, 
    input [1:0] c3, 
    input clk, rst, 
    input [7:0] mc_en, 
    input [7:0] rk_delayed_out, rk_last_out);

    
    logic [7:0] sr_in, sr_out, s_out, mc_out0, mc_out1, mc_out2, mc_out3, sbox_o;
    logic [31:0] pdin;



    permutator permutate (.clk(clk), 
                         .rst(rst), 
                         .d_in(sr_in), 
                         .d_out(sr_out), 
                         .c3(c3));
  
    parll_serl_conv parlltoser (.clk(clk), 
                        .rst(rst), 
                        .din(d_in),
                        .dout(s_out), 
                        .pdin(pdin),
                        .pld(pld));
  
  
  mixcolumn_8 mixer (.clk(clk), 
                  .rst(rst),
                  .din(sbox_o),
                  .en(mc_en),
                  .dout0(mc_out0),
                  .dout1(mc_out1),
                  .dout2(mc_out2),
                     .dout3(mc_out3));
  
  
  bSbox canright_sbox (.A(sr_out), 
                       .Q(sbox_o));
  
    assign pdin = {mc_out0, mc_out1, mc_out2, mc_out3};
    assign sr_in = rk_delayed_out ^ s_out;
    assign d_out = sbox_o ^ rk_last_out;
endmodule
