interface ahb_intf(input logic hclk, hresetn);
	//Arbitration
	bit hbusreq;
	bit hgrant;

	//data
	bit [31:0] haddr;
	bit [31:0] hrdata;
	bit [31:0] hwdata;
	bit hwrite;
	bit [1:0] htrans;
	bit hready;
	bit [2:0] hburst;
	bit [1:0] hresp;
endinterface
