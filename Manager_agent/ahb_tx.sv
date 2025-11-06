// `include "uvm_macros.svh"
// import uvm_pkg :: *;


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
    `uvm_field_int      (rdata,     UVM_DEFAULT)  
  `uvm_object_utils_end

  
  constraint disable_burst_wrap {
  	burst != WRAP4;
    burst != WRAP8;
    burst != WRAP16;
  
  };
  
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
  
  constraint alignd_only {
      addr % (2 ** size) == 0;
  };
  

  constraint burst_default {
      soft burst == INCR4; // default INCR4 
  };
  constraint beat_default {
      soft size == 2; // 32 bit bus
  };
  
  constraint burst_weights {burst dist {INCR4:=10, INCR8:=10, INCR16:=10, SINGLE:=5};};
  int txsize, lower_wrap_addr, upper_wrap_addr;
  
  function void calc_wrap_bound();
    txsize = length * (2**size);
    lower_wrap_addr = addr - (addr % txsize);
    upper_wrap_addr = addr + txsize -1;
  endfunction
 
  function void post_randomize();
    calc_wrap_bound();
  endfunction  

endclass  : m_a_transaction
