`include "aes_pkg.sv"
  import aes_pkg::*;

  `include "uvm_macros.svh";
  import uvm_pkg::*;

  `include "../Design_files/aes_plus_bist_top.sv"
    `include "assert_module.sv"
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

  aes_top_bist_assert assertmodule(
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












