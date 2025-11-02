`include "uvm_macros.svh"
import uvm_pkg :: *;


enum  {active, passive} active_passive_agent = active;


class m_a_transaction extends uvm_sequence_item;
  `uvm_object_utils(m_a_transaction)
  	
  function new(string name = "m_a_transaction");
    super.new(name);
  endfunction
  
endclass 


class m_a_sequence extends uvm_sequence #(m_a_transaction);
  `uvm_object_utils(m_a_sequence)  
  
  function new(string name = "m_a_sequence");
    super.new(name);
  endfunction
  
endclass



class m_a_driver extends uvm_driver;
  `uvm_component_utils(m_a_driver)
  
  function new(string name = "m_a_transaction", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass



class m_a_monitor extends uvm_monitor;
  `uvm_component_utils(m_a_monitor)
  
  function new(string name = "m_a_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass



class m_a_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(m_a_scoreboard)
  
  function new(string name = "m_a_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass


class m_a_agent extends uvm_agent;
  `uvm_component_utils(m_a_scoreboard)
  
  function new(string name = "m_a_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass

