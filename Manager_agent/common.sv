`include "uvm_macros.svh"
import uvm_pkg :: *;

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

enum  {active, passive} active_passive_agent = active;

