import uvm_pkg::*;
`include "uvm_macros.svh"
    
class aes_agent extends uvm_agent;
    `uvm_component_utils(aes_agent)
  
   
    uvm_sequencer #(aes_tran) sqr;
    aes_drv drv;
    aes_monitor mon;
  
   
    uvm_active_passive_enum is_active = UVM_ACTIVE;
  
 
    function new(string name = "aes_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction
  
  
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
  
     
      if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
        is_active = UVM_ACTIVE;
  
  
      mon = aes_monitor::type_id::create("mon", this);
  
     
      if (is_active == UVM_ACTIVE) begin
        sqr = uvm_sequencer#(aes_tran)::type_id::create("sqr", this);
        drv = aes_drv::type_id::create("drv", this);
      end
    endfunction
  
   
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
  
      if (is_active == UVM_ACTIVE)
        drv.seq_item_port.connect(sqr.seq_item_export);
  
   
    endfunction
  
  endclass
  