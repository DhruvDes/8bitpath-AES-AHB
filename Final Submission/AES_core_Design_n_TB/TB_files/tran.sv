import uvm_pkg::*;
`include "uvm_macros.svh"
    
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