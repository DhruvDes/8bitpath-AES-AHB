`include "uvm_macros.svh";
// `include "aes_dpi_pkg.sv"
import uvm_pkg::*;

  import "DPI-C" function void aes_encrypt_dpi(
    input logic [127:0] plaintext,
    input logic [127:0] key,
    output logic [127:0] ciphertext
  );

class aes_tran extends uvm_sequence_item;

function new(string name = "aes_tran");
    super.new(name);
endfunction
rand logic rst;
// logic clk
rand logic [127:0] Plaintext;
rand logic [127:0] Key;
logic [7:0]key_in; 
logic [7:0]d_in;
  logic [127:0] Ciphertext;
// logic d_out
// logic d_vld
// logic DONE
rand logic is_bist;
rand logic en_lsfr_misr;

`uvm_object_utils_begin(aes_tran) 
  `uvm_field_int(rst, UVM_DEFAULT)
`uvm_field_int(Plaintext, UVM_DEFAULT)
`uvm_field_int(Key, UVM_DEFAULT)
  `uvm_field_int(Ciphertext, UVM_DEFAULT)
`uvm_field_int(is_bist, UVM_DEFAULT)
`uvm_field_int(en_lsfr_misr, UVM_DEFAULT)
//   `uvm_field_int(key_in, UVM_DEFAULT)
//   `uvm_field_int(d_in, UVM_DEFAULT)
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


class random_test_no_bist extends uvm_sequence_base;
`uvm_object_utils(random_test_no_bist)

function  new(string name = "random_test_no_bist");
    super.new(name);
endfunction
    
 aes_tran req;
task  body();
  req = aes_tran :: type_id :: create("req");
  `uvm_do_with(req,{
                    req.rst == 0;
                      is_bist == 0;
    });

endtask

endclass


class bist_check extends uvm_sequence_base;
  `uvm_object_utils(bist_check)

function  new(string name = "bist_check");
    super.new(name);
endfunction
    
aes_tran req;
task  body();
  req = aes_tran :: type_id :: create("req");
  `uvm_do_with(req,{
                    req.rst == 0;
                      is_bist == 1;
    });

endtask

endclass


class rndom_testing extends uvm_sequence_base;
  `uvm_object_utils(rndom_testing)

  function new(string name = "rndom_testing");
    super.new(name);
  endfunction
    
  aes_tran req;

task body();
  req = aes_tran::type_id::create("req");
//   `uvm_do_with(req, {
//     req.rst == 0;
//     req.is_bist dist {0 := 99};

//     // Weighted randomization for variety
//     req.Key dist { 
//       128'h0                                       := 1,
//       128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 1,
//       128'hAA55_AA55_AA55_AA55_AA55_AA55_AA55_AA55 := 1,
//       [128'h0000_0000_0000_0000_0000_0000_0000_0000 :
//        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF] := 20
//     };

//     req.Plaintext dist { 
//       128'h0                                       := 1,
//       128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 1,
//       128'hAA55_AA55_AA55_AA55_AA55_AA55_AA55_AA55 := 1,
//       [128'h0000_0000_0000_0000_0000_0000_0000_0000 :
//        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF] := 20
//     };
//   })
  `uvm_do_with(req, {rst== 0;})
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
//     req.print();
    seq_item_port.item_done();

end

endtask


task drive_dut();
  // Apply reset
  
  aes_if.rst <= req.rst;
  aes_if.is_bist <= req.is_bist;
  aes_if.en_lsfr_misr <= req.en_lsfr_misr;

  if (req.rst) begin
  
    aes_if.rst <= req.rst;
    aes_if.key_in <= 8'h00;
    aes_if.d_in   <= 8'h00;  
    @(negedge aes_if.clk);
    
  
  end

  // Drive key and plaintext bytes over 16 clock cycles
  else begin
  
  aes_if.rst <= req.rst;
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
  
    wait(aes_if.DONE) ; 
  @(negedge aes_if.clk); 
  aes_if.rst <= 1;
    @(negedge aes_if.clk);

  end


 

endtask

endclass


class aes_monitor extends uvm_monitor;
  `uvm_component_utils(aes_monitor)

  virtual aes_bist_if aes_if;
  uvm_analysis_port#(aes_tran) ap;
   aes_tran tr;

  // Local accumulators for building 128-bit words
  logic [127:0] Key;
  logic [127:0] Plaintext;
  logic [127:0] Ciphertext;
  int byte_count_in;
  int byte_count_out;

  function new(string name = "aes_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual aes_bist_if)::get(this, "interface", "aes_if", aes_if))
      `uvm_fatal("MON_IF", "Failed to get aes_if handle from config DB")
  endfunction

  task run_phase(uvm_phase phase);
   
	tr = aes_tran::type_id::create("input_tr", this);
    // initialize
    Key           = '0;
    Plaintext     = '0;
    Ciphertext    = '0;
    byte_count_in = 0;
    byte_count_out = 0;

    forever begin
      @(posedge aes_if.clk);
      tr.rst = aes_if.rst;
      tr.is_bist = aes_if.is_bist;
      tr.en_lsfr_misr = aes_if.en_lsfr_misr;
      // --- INPUT CAPTURE PHASE ---
      // Collect 16 bytes of key and plaintext as they are driven in
      if (!aes_if.rst && !aes_if.is_bist && !aes_if.d_vld && !aes_if.DONE && byte_count_in != 16) begin
        Key       = {Key[119:0], aes_if.key_in};   // shift left 8 bits, append new byte
        Plaintext = {Plaintext[119:0], aes_if.d_in};
        byte_count_in++;

        if (byte_count_in == 16) begin
       
          tr.Key       = Key;
          tr.Plaintext = Plaintext;
          tr.rst = aes_if.rst;
          tr.is_bist = aes_if.is_bist;
          tr.en_lsfr_misr = aes_if.en_lsfr_misr;
          

        end
      end

      // --- OUTPUT CAPTURE PHASE ---
      // When DUT asserts d_vld, collect ciphertext bytes
      if (aes_if.d_vld) begin
        Ciphertext = {Ciphertext[119:0], aes_if.d_out};
        byte_count_out++;

        if (byte_count_out == 16) begin
     
          tr.Ciphertext = Ciphertext;
          ap.write(tr);
          `uvm_info("AES_MON",
                    $sformatf("Captured full Ciphertext = %h", Ciphertext),
                    UVM_MEDIUM)
          byte_count_out = 0;
          Ciphertext     = '0;
          byte_count_in = 0;
          Key           = '0;
          Plaintext     = '0;
        end
      end
    end
  endtask

endclass


class aes_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(aes_scoreboard)

  // Analysis port from the monitor
  uvm_analysis_imp#(aes_tran, aes_scoreboard) analysis_export;


  
  // Store latest input vectors
  logic [127:0] key, last_key;
  logic [127:0] last_plaintext, Plaintext;

  // Temporary storage for expected and actual outputs
  logic [127:0] expected_output;
  logic [127:0] actual_output;
  int kt, pt;
  static int num_trans;
  
  
  
// covergroup aes_cg;
//   key_cp : coverpoint kt
//   {
//     bins all_zero      = {0};
//     bins all_one       = {1};
//     bins alt_bits      = {2};
//     bins single_bit    = {3};
//     bins low_weight    = {4};
//     bins high_weight   = {5};
//     bins random_other  = {6};
//   }

//   pt_cp : coverpoint pt 
//   {
//     bins all_zero      = {0};
//     bins all_one       = {1};
//     bins alt_bits      = {2};
//     bins single_bit    = {3};
//     bins low_weight    = {4};
//     bins high_weight   = {5};
//     bins random_other  = {6};
//   }
  


// //   ct_cross : cross key_cp, pt_cp;
// endgroup
  
covergroup aes_cg;
  key_cp : coverpoint kt {
    // create an automatic bin for each unique value seen, up to a limit
    option.auto_bin_max = 64; // change as needed (limits #bins)
  }
  pt_cp : coverpoint pt {
    option.auto_bin_max = 64;
  }
    cross key_cp, pt_cp;
endgroup
  
  function new(string name = "aes_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    aes_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_export = new("analysis_export", this);
  endfunction        

  // Called automatically whenever monitor writes a transaction
  function void write(aes_tran tr);
//     tr.print();
	num_trans++;
    // Case 1: Input transaction
    if (tr.Ciphertext === '0) begin
      last_key       = tr.Key;
      last_plaintext = tr.Plaintext;
      `uvm_info("SCOREBOARD", 
                $sformatf("Received INPUT: Key=%h Plaintext=%h",
                          last_key, last_plaintext),
                UVM_MEDIUM)
    end else if (tr.is_bist == 1) begin 
//       `uvm_info(get_type_name(), $sformatf("Entered BIST branch correctely"), UVM_LOW);
      if (tr.Ciphertext[7:0] == 8'hc0) begin 
        `uvm_info(get_type_name(), $sformatf("BIST passed"), UVM_MEDIUM)
      		aes_cg.sample();
      end else begin 
      
        `uvm_error(get_type_name(), $sformatf("BIST failed"))
      end 
      
      
    end else begin
      actual_output   = tr.Ciphertext;
      expected_output = aes_reference_model(tr.Key, tr.Plaintext);

      if (actual_output !== expected_output)
        `uvm_error("AES_MISMATCH",
                   $sformatf("Ciphertext mismatch!\n  Expected: %h\n  Got: %h",
                             expected_output, actual_output))
      else
        `uvm_info("SCOREBOARD", "AES encryption MATCH", UVM_MEDIUM)
        kt = tr.Key;
        pt = tr.Plaintext;
        aes_cg.sample();
    end
  endfunction

  // Reference model (calls DPI-C AES)
  function logic [127:0] aes_reference_model(
      logic [127:0] key, logic [127:0] plaintext);
    logic [127:0] ciphertext;
    aes_encrypt_dpi(plaintext, key, ciphertext);
    return ciphertext;
  endfunction
      
      
//   function int classify_pattern(logic [127:0] val);
//     int weight = $countones(val);
//     if (val == 128'h0)                          return 0; // all zero
//     else if (val == 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF) return 1; // all one
//     else if (val == 128'hAA55_AA55_AA55_AA55_AA55_AA55_AA55_AA55) return 2; // alternating
//     else if (weight == 1)                       return 3; // single bit
//     else if (weight inside {[2:8]})             return 4; // low weight
//     else if (weight inside {[120:127]})         return 5; // high weight
//     else                                        return 6; // random
//   endfunction
endclass



class aes_env extends uvm_env;
  `uvm_component_utils(aes_env)

  uvm_sequencer #(aes_tran) sqr;
  aes_drv drv;
  aes_monitor mon;
  aes_scoreboard scb;

  function new(string name = "aes_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = uvm_sequencer#(aes_tran)::type_id::create("sqr", this);
    drv = aes_drv::type_id::create("drv", this);
    mon = aes_monitor::type_id::create("mon", this);
    scb = aes_scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
    mon.ap.connect(scb.analysis_export);
  endfunction
endclass



class aes_test extends uvm_test;
  `uvm_component_utils(aes_test)

  aes_env env;
  uvm_sequencer#(aes_tran) sqr;
  quick_visual_test seq;
  reset_test rst_test;
  random_test_no_bist rd_t_n_b;
  bist_check bst_chk;
  rndom_testing rnd_tst;
  
  function new(string name = "aes_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = aes_env::type_id::create("env", this);
    seq = quick_visual_test::type_id::create("seq");
    rst_test = reset_test::type_id::create("rst_test");
    rd_t_n_b = random_test_no_bist :: type_id :: create("random_test_no_bist"); 
    bst_chk = bist_check  :: type_id :: create("bst_chk"); 
    rnd_tst = rndom_testing :: type_id :: create("rnd_tst");
  endfunction

  task run_phase(uvm_phase phase);
 
    phase.raise_objection(this);
	
    repeat(2)rst_test.start(env.sqr);
      
    repeat(10)rnd_tst.start(env.sqr);
    seq.start(env.sqr);
    seq.start(env.sqr);
    rd_t_n_b.start(env.sqr);
    seq.start(env.sqr);
    bst_chk.start(env.sqr);
    rd_t_n_b.start(env.sqr);
      
    
    while (env.scb.aes_cg.get_coverage() < 10) begin 
//       	`uvm_info(get_type_name(), $sformatf("Coverage : %f", env.scb.aes_cg.get_coverage()), UVM_NONE);
        rnd_tst.start(env.sqr);
    
    end
    
    #200; // let it run for a bit
    phase.drop_objection(this);
  endtask
  
  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Coverage : %f", env.scb.aes_cg.get_coverage()), UVM_NONE);
    `uvm_info(get_type_name(), $sformatf("Number of transaction : %f", env.scb.num_trans), UVM_NONE);
  endfunction
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
    forever #1 aes_if.clk = ~aes_if.clk;
  end

  // Reset and UVM setup
  initial begin


    // Pass interface to UVM components
    uvm_config_db#(virtual aes_bist_if)::set(null, "*.interface", "aes_if", aes_if);
    uvm_top.set_report_verbosity_level(UVM_LOW);
    // Start the UVM test
    run_test("aes_test");
  end
  
  initial  begin 
    $dumpvars();
    $dumpfile("dump.vcd");
  end

endmodule



// module aes_test;



//   logic [127:0] pt;
//   logic [127:0] key;
//   logic [127:0] ct;

//   initial begin
//     pt  = 128'h00112233445566778899aabbccddeeff;
//     key = 128'h000102030405060708090a0b0c0d0e0f;

//     $display("[SV] Plaintext  = %032h", pt);
//     $display("[SV] Key        = %032h", key);

//     aes_encrypt_dpi(pt, key, ct);

//     $display("[SV] Ciphertext = %h", ct);
//     $finish;
//   end

// endmodule


