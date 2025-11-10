`include "uvm_macros.svh"
`include "aes_dpi_pkg.sv"
import uvm_pkg::*;


class aes_tran extends uvm_sequence_item;

function new(string name = "aes_tran");
    super.new(name);
endfunction
rand logic rst;
// logic clk
rand logic [127:0] Plaintext;
rand logic [127:0] Key;
// logic [7:0]key_in; 
// logic [7:0]d_in;
// logic d_out
// logic d_vld
// logic DONE
rand logic is_bist;
rand logic en_lsfr_misr;

`uvm_object_utils_begin(aes_tran) 
  `uvm_field_int(rst, UVM_DEFAULT)
`uvm_field_int(Plaintext, UVM_DEFAULT)
`uvm_field_int(Key, UVM_DEFAULT)
`uvm_field_int(is_bist, UVM_DEFAULT)
`uvm_field_int(en_lsfr_misr, UVM_DEFAULT)
`uvm_object_utils_end;

  constraint bist_en_same {is_bist == en_lsfr_misr;};

endclass



class aes_sequence_base extends uvm_sequence#(aes_tran);
`uvm_object_utils(aes_sequence_base)

function  new(string name = "aes_sequence_base");
    super.new(name);
endfunction


task pre_body();
    if(starting_phase != null);
    starting_phase.raise_objection(this);
endtask



task post_body();
        if(starting_phase != null);
    starting_phase.drop_objection(this);
endtask

endclass

class reset_test extends uvm_sequence_base;
  `uvm_object_utils(reset_test)
function  new(string name = "quick_visual_test");
    super.new(name);
endfunction
    
 aes_tran req;
task  body();
  req = aes_tran :: type_id :: create("req");
  `uvm_do_with(req,{req.Key == 128'h0;
                    req.Plaintext == 128'h0;
                    req.rst == 1;
                    is_bist == 0;
    });

endtask

endclass


class quick_visual_test extends uvm_sequence_base;
`uvm_object_utils(quick_visual_test)

function  new(string name = "quick_visual_test");
    super.new(name);
endfunction
    
 aes_tran req;
task  body();
  req = aes_tran :: type_id :: create("req");
  `uvm_do_with(req,{req.Key == 128'h000102030405060708090a0b0c0d0e0f;
                    req.Plaintext == 128'h00112233445566778899aabbccddeeff;
                    req.rst == 0;
                      is_bist == 0;
    });

endtask

endclass



class aes_drv extends uvm_driver#(aes_tran);
`uvm_component_utils(aes_drv)
function  new(string name = "aes_drv", uvm_component parent = null);
    super.new(name,parent);
endfunction

uvm_sequencer#(aes_tran) sqr;
virtual aes_bist_if aes_if;
aes_tran req;

function void build_phase(uvm_phase phase);
super.build_phase(phase);
  req = aes_tran :: type_id :: create("req");
// sqr = uvm_sequencer#(aes_tran) :: type_id :: create("sqr", this);
assert (uvm_config_db#(virtual aes_bist_if) :: get(this, "interface","aes_if", aes_if))  else begin 
`uvm_error(get_type_name(), $sformatf("%0p", this));
end
    
endfunction


task run_phase(uvm_phase phase);

forever begin 
  seq_item_port.get_next_item(req);
    drive_dut();
    req.print();
    seq_item_port.item_done();

end

endtask


task drive_dut();
  // Apply reset
  
  aes_if.rst <= req.rst;
  aes_if.is_bist <= req.is_bist;
  aes_if.en_lsfr_misr <= req.en_lsfr_misr;

  if (req.rst) begin
    @(negedge aes_if.clk);
    aes_if.rst <= req.rst;
    aes_if.key_in <= req.Key;
    aes_if.d_in   <= req.Plaintext;
    
  
  end

  // Drive key and plaintext bytes over 16 clock cycles
  else begin
    
  aes_if.rst <= req.rst;
  aes_if.is_bist <= req.is_bist;
  aes_if.en_lsfr_misr <= req.en_lsfr_misr;

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[127:120];
  aes_if.d_in   <= req.Plaintext[127:120];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[119:112];
  aes_if.d_in   <= req.Plaintext[119:112];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[111:104];
  aes_if.d_in   <= req.Plaintext[111:104];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[103:96];
  aes_if.d_in   <= req.Plaintext[103:96];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[95:88];
  aes_if.d_in   <= req.Plaintext[95:88];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[87:80];
  aes_if.d_in   <= req.Plaintext[87:80];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[79:72];
  aes_if.d_in   <= req.Plaintext[79:72];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[71:64];
  aes_if.d_in   <= req.Plaintext[71:64];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[63:56];
  aes_if.d_in   <= req.Plaintext[63:56];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[55:48];
  aes_if.d_in   <= req.Plaintext[55:48];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[47:40];
  aes_if.d_in   <= req.Plaintext[47:40];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[39:32];
  aes_if.d_in   <= req.Plaintext[39:32];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[31:24];
  aes_if.d_in   <= req.Plaintext[31:24];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[23:16];
  aes_if.d_in   <= req.Plaintext[23:16];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[15:8];
  aes_if.d_in   <= req.Plaintext[15:8];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[7:0];
  aes_if.d_in   <= req.Plaintext[7:0];
      wait(aes_if.DONE);
  end


 

endtask

endclass


class aes_env extends uvm_env;
  `uvm_component_utils(aes_env)

  uvm_sequencer #(aes_tran) sqr;
  aes_drv drv;

  function new(string name = "aes_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = uvm_sequencer#(aes_tran)::type_id::create("sqr", this);
    drv = aes_drv::type_id::create("drv", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass



class aes_test extends uvm_test;
  `uvm_component_utils(aes_test)

  aes_env env;
  uvm_sequencer#(aes_tran) sqr;
  quick_visual_test seq;
  reset_test rst_test;
  
  function new(string name = "aes_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = aes_env::type_id::create("env", this);
    seq = quick_visual_test::type_id::create("seq");
    rst_test = reset_test::type_id::create("rst_test");
  endfunction

  task run_phase(uvm_phase phase);
 
    phase.raise_objection(this);
	
    repeat(2)rst_test.start(env.sqr);
    
    seq.start(env.sqr);

    #100; // let it run for a bit
    phase.drop_objection(this);
  endtask
endclass




module tb;

  // Instantiate the interface
  aes_bist_if aes_if();

  // Instantiate DUT and connect ports
  aes_top_bist test (
    .rst(aes_if.rst), 
    .clk(aes_if.clk), 
    .key_in(aes_if.key_in), 
    .d_in(aes_if.d_in), 
    .d_out(aes_if.d_out), 
    .d_vld(aes_if.d_vld), 
    .DONE(aes_if.DONE), 
    .is_bist(aes_if.is_bist), 
    .en_lsfr_misr(aes_if.en_lsfr_misr)
  );

  // Clock generation
  initial begin
    aes_if.clk = 0;
    forever #5 aes_if.clk = ~aes_if.clk;
  end

  // Reset and UVM setup
  initial begin


    // Pass interface to UVM components
    uvm_config_db#(virtual aes_bist_if)::set(null, "*.interface", "aes_if", aes_if);

    // Start the UVM test
    run_test("aes_test");
  end
  
  initial  begin 
    $dumpvars();
    $dumpfile("dump.vcd");
  end

endmodule
