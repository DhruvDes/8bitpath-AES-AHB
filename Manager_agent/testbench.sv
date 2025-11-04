// Code your testbench here
// or browse Examples


`include "master_agent_pkg.sv"
import  master_agent_pkg :: *;



module tb;
  
  
  m_a_transaction tr;
  
  initial begin 
    tr = new();
    
    assert(tr.randomize());
    
    tr.print();
  
  end
  
  
endmodule