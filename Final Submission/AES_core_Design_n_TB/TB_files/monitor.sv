import uvm_pkg::*;
`include "uvm_macros.svh"
    
class aes_monitor extends uvm_monitor;
    `uvm_component_utils(aes_monitor)
  
    virtual aes_bist_if aes_if;
    uvm_analysis_port#(aes_tran) ap;
     aes_tran tr;
  
    // Local accumulators for building 128-bit words
    logic [127:0] Key;
    logic [127:0] Plaintext;
    logic [127:0] Ciphertext;
    logic [127:0] byte_count_in;
    logic [127:0] byte_count_out;
  
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
  