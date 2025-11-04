`include "uvm_macros.svh"
import uvm_pkg :: *;


enum  {active, passive} active_passive_agent = active;

typedef enum bit [2:0] {
	SINGLE = 3'b0,
  	INCR = 3'b001,
  	WRAP4 = 3'b010,
  	INCR4 = 3'b011,
  	WRAP8 = 3'b100,
  	INCR8 = 3'b101,
  	WRAP16 = 3'b110,
  	INCR16 = 3'b111
} burst_t;


class m_a_transaction extends uvm_sequence_item;
  	
  function new(string name = "m_a_transaction");
    super.new(name);
  endfunction
  
  

  rand bit [31:0] addr;
  rand bit [31:0] dataQ[$];
  rand bit [2:0]  size;
  rand bit [6:0]  prot;
  rand bit [4:0]  length;
  rand burst_t    burst;
  rand bit        wr_rd;
  rand bit        excl;
  rand bit        nonsec;
  rand bit        mastlock;

// responds from subor
  bit [1:0] resp;
  bit       exokay;
  bit [31:0]rdata; 
  
  `uvm_object_utils_begin(m_a_transaction)
    `uvm_field_int      (addr,      UVM_DEFAULT)
    `uvm_field_queue_int(dataQ,     UVM_DEFAULT)
    `uvm_field_int      (size,      UVM_DEFAULT)
    `uvm_field_int      (prot,      UVM_DEFAULT)
    `uvm_field_int      (length,    UVM_DEFAULT)
    `uvm_field_enum     (burst_t, burst, UVM_DEFAULT)
    `uvm_field_int      (wr_rd,     UVM_DEFAULT)
    `uvm_field_int      (excl,      UVM_DEFAULT)
    `uvm_field_int      (nonsec,    UVM_DEFAULT)
    `uvm_field_int      (mastlock,  UVM_DEFAULT)
    `uvm_field_int      (resp,      UVM_DEFAULT)
    `uvm_field_int      (exokay,    UVM_DEFAULT)
  `uvm_object_utils_end

  
  constraint burst_lenght_c {
  		
    (burst == SINGLE) -> (length == 1);
    (burst inside {INCR4, WRAP4}) -> (length == 4);
    (burst inside {INCR8, WRAP8}) -> (length == 8);
    (burst inside {INCR16, WRAP16}) -> (length == 16);
    length inside {[1:16]}; 
  };
  
  constraint dataq_c {
    dataQ.size() == length;
  };
  
  
  function void calc_wrap_bound();
    txsize = len * (2**size);
    lower_wrap_addr = addr - (addr % txsize);
    upper_wrap_addr = addr + txsize -1;
  endfunction
  
  
  
  
  
  
endclass  : m_a_transaction




class m_a_sequence extends uvm_sequence #(m_a_transaction);
  `uvm_object_utils(m_a_sequence)  
  
  function new(string name = "m_a_sequence");
    super.new(name);
  endfunction
  
  
  
  task run_phases(uvm_phase phase);
  
  endtask
  
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

