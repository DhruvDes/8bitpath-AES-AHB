module ahb_bist_assert_only(
  input logic hrstn,
  input logic hclk,
  input logic hsel,
  input logic [31:0] haddr,
  input logic [1:0]htrans, // IDLE //Busy //NONseq //SEQ 
  input logic hwrite, 
  input logic [2:0]hsize, //00-8bit  //01-16bit //10-32bit //Throw err = hresp=1
  input logic [31:0]hwdata, // manager to subord
  input logic hready, // sub to manager
  input logic [31:0]hrdata, // subord to manager
  input logic hreadyOut, // to the multiplexor but to manager in our case
  input logic hresp, // 0-okay 1-error
  input logic [2:0]hburst
);




property hrout_go_low_2c_write;

@ (posedge hclk) disable iff (hrstn == 0) (haddr == 32'h2c) |=> ##[1:2] hreadyOut == 0; 

endproperty

property hrout_comes_back_up;
    @ (posedge hclk) disable iff (hrstn == 0) $fell(hreadyOut) |=> ##[1:$] hreadyOut == 1;
endproperty 

logic illegal_access;
assign illegal_access =
       (haddr  > 32'h3c) ||
       (hsize != 2) ||
       (hburst == 3'b010)||
       (hburst == 3'b100)||
       (hburst == 3'b110)||
       (hburst == 3'b111)||
       (hburst == 3'b001);


property issue_hresp_responsibily;
    @ (posedge hclk) disable iff (hrstn == 0) illegal_access |=> hresp;
endproperty

property hresp_returns_to_normal;
    @ (posedge hclk) disable iff (hrstn == 0) $rose(hresp) |=> ##[1:$] $fell(hresp);
endproperty



Hrout_go_low_2c_write: assert property (hrout_go_low_2c_write);
Hrout_comes_back_up: assert property (hrout_comes_back_up) ;
Issue_hresp_responsibily: assert property (issue_hresp_responsibily);
Hresp_returns_to_normal: assert property (hresp_returns_to_normal);


endmodule