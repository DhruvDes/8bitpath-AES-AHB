interface ahb_if();

logic hrstn;
  logic hclk;
logic hsel;
logic [31:0] haddr;
logic [1:0]htrans; // IDLE //Busy //NONseq //SEQ 
logic hwrite; 
logic [2:0]hsize; //00-8bit  //01-16bit //10-32bit //Throw err = hresp=1
logic [31:0]hwdata; // manager to subord
logic hready; // sub to manager
logic [31:0]hrdata; // subord to manager
logic hreadyOut; // to the multiplexor but to manager in our case
logic hresp; // 0-okay 1-error
logic [2:0]hburst;
  
  




clocking m_cb @(posedge hclk);
  default input #0 output #1;  


  output hsel;
  output haddr;
  output htrans;
  output hwrite;
  output hsize;
  output hwdata;
  output hburst;
  output hready;


 
  input  hreadyOut;
  input  hrdata;
  input  hresp;
endclocking











endinterface