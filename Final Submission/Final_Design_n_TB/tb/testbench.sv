
`include "all_intf.sv"
`include "design.sv"

`include "ahb_pkg.sv"
import ahb_pkg :: *;

`include "uvm_macros.svh"
import uvm_pkg :: *;
`include "ahb_assert_mosule.sv" 


module tb;

//   virtual subor_if.subord s_vif();
 
  ahb_if ahb_vif();
	
  ip_top ip_dut(
  	.HCLK(ahb_vif.hclk),
    .HRESETn(ahb_vif.hrstn),
    .HSEL(ahb_vif.hsel),
    .HADDR(ahb_vif.haddr),
    .HTRANS(ahb_vif.htrans),
    .HWRITE(ahb_vif.hwrite),
    .HSIZE(ahb_vif.hsize),
    .HWDATA(ahb_vif.hwdata),
    .HREADY(ahb_vif.hready),
    .HBURST(ahb_vif.hburst),
    .HRDATA(ahb_vif.hrdata),
    .HREADYOUT(ahb_vif.hreadyOut),
    .HRESP(ahb_vif.hresp)
  );

  bind ip_dut ahb_bist_assert_only dut_assert(
  	.hclk(ahb_vif.hclk),
    .hrstn(ahb_vif.hrstn),
    .hsel(ahb_vif.hsel),
    .haddr(ahb_vif.haddr),
    .htrans(ahb_vif.htrans),
    .hwrite(ahb_vif.hwrite),
    .hsize(ahb_vif.hsize),
    .hwdata(ahb_vif.hwdata),
    .hready(ahb_vif.hready),
    .hburst(ahb_vif.hburst),
    .hrdata(ahb_vif.hrdata),
    .hreadyOut(ahb_vif.hreadyOut),
    .hresp(ahb_vif.hresp)
  );

  initial begin 
    ahb_vif.hclk = 0;
    ahb_vif.hrstn = 0;
    #10;
    ahb_vif.hrstn =1;
  end
  always #5 ahb_vif.hclk = ~ahb_vif.hclk;

initial begin 
  uvm_config_db#(virtual ahb_if)::set(null,"*.interface","ahb_vif",ahb_vif);

//   uvm_config_db#(virtual ahb_if.mangr_mp)::set(
//       null, "*.interface", "m_vif", ahb_vif);
  
  
//   uvm_config_db#(virtual ahb_if.subor_mp)::set(
//       null, "*.interface", "s_vif", ahb_vif.subor_mp);
  
  //  run_test("r_w_1_test");
  // run_test("manual_rw");
  run_test("complete_test");
end
  
  initial begin 
    $dumpvars;
    $dumpfile("dump.vcd");
  
  end

endmodule

