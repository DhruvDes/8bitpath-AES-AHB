import uvm_pkg::*;
`include "uvm_macros.svh"
    
class aes_env extends uvm_env;
    `uvm_component_utils(aes_env)
  
    aes_agent agent;
    aes_scoreboard scb;
  
    function new(string name = "aes_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      agent = aes_agent::type_id::create("agent", this);
      scb   = aes_scoreboard::type_id::create("scb", this);
    endfunction
  
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
  
      // Monitor pushes transactions to scoreboard
      agent.mon.ap.connect(scb.analysis_export);
    endfunction
  
  endclass
  
// class aes_env extends uvm_env;
//     `uvm_component_utils(aes_env)
  
//     uvm_sequencer #(aes_tran) sqr;
//     aes_drv drv;
//     aes_monitor mon;
//     aes_scoreboard scb;
  
//     function new(string name = "aes_env", uvm_component parent = null);
//       super.new(name, parent);
//     endfunction
  
//     function void build_phase(uvm_phase phase);
//       super.build_phase(phase);
//       sqr = uvm_sequencer#(aes_tran)::type_id::create("sqr", this);
//       drv = aes_drv::type_id::create("drv", this);
//       mon = aes_monitor::type_id::create("mon", this);
//       scb = aes_scoreboard::type_id::create("scb", this);
//     endfunction
  
//     function void connect_phase(uvm_phase phase);
//       drv.seq_item_port.connect(sqr.seq_item_export);
//       mon.ap.connect(scb.analysis_export);
//     endfunction
//   endclass
  