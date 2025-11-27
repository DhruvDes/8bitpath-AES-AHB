// Code your testbench here
// or browse Examples

`include "uvm_macros.svh"
import uvm_pkg :: *;

`include "ahb_pkg.sv"
import ahb_pkg :: *;

module top;

//   virtual subor_if.subord s_vif();
  virtual ahb_intf ahb_vif;
  
initial begin 
  uvm_config_db#(virtual ahb_intf)::set(null,"*","m_vif",ahb_vif);
//   uvm_config_db#(virtual subor.subord):: get(this,"interface","m_vif", s_vif) 
    run_test("ahb_base_test");
end

endmodule





