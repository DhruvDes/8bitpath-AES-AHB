// please input all your top module inpuit and outputs here



interface interfaces 


//GLOBAL
logic HCLK;
logic HRESETn;

////////////// AHB SIGNALS ////////////////////////////////////
// MANAGER SIGNALS
logic [31:0] HADDR;
logic [2:0] HBURST;
logic HMASTLOCK;
logic [6:0] HPROT;
logic [1:0] HSIZE; // because the max size we can transfer is 32bits in one cycle
logic [1:0] HTRANS;
logic [31:0] HWDATA;
logic [3:0] HWSTRB;
logic HWRITE; // when high - Writer transfer, when low - Read transfer.

// SUBORDINATE SIGNALS
logic [31:0] HRDATA;
logic HREADYOUT;
logic HRESP;
logic HEXOKAY;

//DECODER SIGNALS
logic HSEL_1;


modport manager(input HCLK, HRESETn,
                output HADDR, HBURST, HMASTLOCK, HPROT, 
                HSIZE, HTRANS, HWDATA, HWSTRB, HWRITE
                );

modport subordinate(
        input HCLK, HRESETn, HSEL_1,HADDR, HBURST, HMASTLOCK, HPROT, HSIZE,
        HTRANS, HWDATA, HWSTRB, HWRITE,
        output  HRDATA, HREADYOUT, HRESP, HEXOKAY
);

modport decoder (
    input HADDR,
    output HSEL_1

);
////////////// AHB SIGNALS ////////////////////////////////////






endinterface 
