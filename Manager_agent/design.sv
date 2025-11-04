// `include "master_agent_pkg.sv"
// import master_agent_pkg :: *;
//4- 30:36;




// class m_a_sequence extends uvm_sequence #(m_a_transaction);
//   `uvm_object_utils(m_a_sequence)  
  
//   function new(string name = "m_a_sequence");
//     super.new(name);
//   endfunction
  
  
  
//   task run_phases(uvm_phase phase);
  
//   endtask
  
// endclass



// class m_a_driver extends uvm_driver;
//   `uvm_component_utils(m_a_driver)
  
//   function new(string name = "m_a_transaction", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction
  
// endclass



// class m_a_monitor extends uvm_monitor;
//   `uvm_component_utils(m_a_monitor)
  
//   function new(string name = "m_a_monitor", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction
  
// endclass



// class m_a_scoreboard extends uvm_scoreboard;
//   `uvm_component_utils(m_a_scoreboard)
  
//   function new(string name = "m_a_scoreboard", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction
  
// endclass

