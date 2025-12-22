import uvm_pkg::*;
`include "uvm_macros.svh"

import "DPI-C" function void aes_encrypt_dpi(
    input logic [127:0] plaintext,
    input logic [127:0] key,
    output logic [127:0] ciphertext
  );
  

  class aes_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(aes_scoreboard)
  
    uvm_analysis_imp#(aes_tran, aes_scoreboard) analysis_export;
  
    // pattern classes
    logic[127:0] kt, pt;
  
    static int num_trans;
    logic [127:0] expected_output; 
  
    // Covergroup: classification-based coverage
    covergroup aes_cg;

      key_cp : coverpoint kt {
        // option.goal = 100;
        bins all_zero      = {0}; 
        bins all_one       = {1}; 
        bins alt_bits      = {2}; 
        bins single_bit    = {3}; 
        bins low_weight    = {4}; 
        bins high_weight   = {5}; 
        bins random_other  = {6}; 
      }
      
  
      pt_cp : coverpoint pt {
        // option.goal = 100;
        bins all_zero      = {0} ;
        bins all_one       = {1} ;
        bins alt_bits      = {2} ;
        bins single_bit    = {3} ;
        bins low_weight    = {4} ;
        bins high_weight   = {5} ;
        bins random_other  = {6} ;
      }
      
  
      cross key_cp, pt_cp;
    endgroup
  
    function new(string name="aes_scoreboard", uvm_component parent=null);
      super.new(name, parent);
      aes_cg = new();
    endfunction
  
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      analysis_export = new("analysis_export", this);
    endfunction
  
    function void write(aes_tran tr);
      num_trans++;
  
      // Case 1: input phase
      if (tr.Ciphertext === '0) begin
        // do nothing
        return;
      end
  
      // Case 2: BIST
      if (tr.is_bist == 1) begin
        if (tr.Ciphertext[7:0] == 8'hc0) begin
          `uvm_info(get_type_name(),"BIST passed",UVM_MEDIUM)
          aes_cg.sample();
        end else begin
          `uvm_error(get_type_name(),"BIST failed")
        end
        return;
      end
  
      // Case 3: functional AES output
      expected_output = aes_reference_model(tr.Key, tr.Plaintext);
  
      if (tr.Ciphertext !== expected_output) begin
        `uvm_error("AES_MISMATCH",
                   $sformatf("EXPECTED=%h GOT=%h",
                              expected_output, tr.Ciphertext))
      end else begin
        `uvm_info("SCOREBOARD","AES encryption MATCH",UVM_MEDIUM)
  
        // **CLASSIFY VALUES FOR COVERAGE**
        kt = classify_pattern(tr.Key);
        pt = classify_pattern(tr.Plaintext);
  
        aes_cg.sample();
      end
    endfunction
    logic [127:0] weight;
    // 128-bit pattern classifier
    function int classify_pattern(logic [127:0] val);
      weight = $countones(val);
      if      (val == 128'h0) return 0;
      else if (val == 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF) return 1;
      else if (val == 128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA || val == 128'h5555_5555_5555_5555_5555_5555_5555_5555) return 2;
      else if (weight == 1) return 3;
      else if (weight inside {[2:8]}) return 4;
      else if (weight inside {[120:127]}) return 5;
      else return 6;
    endfunction

      function logic [127:0] aes_reference_model(
        logic [127:0] key, logic [127:0] plaintext);
      logic [127:0] ciphertext;
      aes_encrypt_dpi(plaintext, key, ciphertext);
      return ciphertext;
    endfunction
    
  endclass
  




  
// class aes_scoreboard extends uvm_scoreboard;
//     `uvm_component_utils(aes_scoreboard)
  
//     // Analysis port from the monitor
//     uvm_analysis_imp#(aes_tran, aes_scoreboard) analysis_export;
  
  
    
//     // Store latest input vectors
//     logic [127:0] key, last_key;
//     logic [127:0] last_plaintext, Plaintext;
  
//     // Temporary storage for expected and actual outputs
//     logic [127:0] expected_output;
//     logic [127:0] actual_output;
//     int kt, pt;
//     static int num_trans;
    
    
    
//   // covergroup aes_cg;
//   //   key_cp : coverpoint kt
//   //   {
//   //     bins all_zero      = {0};
//   //     bins all_one       = {1};
//   //     bins alt_bits      = {2};
//   //     bins single_bit    = {3};
//   //     bins low_weight    = {4};
//   //     bins high_weight   = {5};
//   //     bins random_other  = {6};
//   //   }
  
//   //   pt_cp : coverpoint pt 
//   //   {
//   //     bins all_zero      = {0};
//   //     bins all_one       = {1};
//   //     bins alt_bits      = {2};
//   //     bins single_bit    = {3};
//   //     bins low_weight    = {4};
//   //     bins high_weight   = {5};
//   //     bins random_other  = {6};
//   //   }
    
  
  
//   // //   ct_cross : cross key_cp, pt_cp;
//   // endgroup
    
//   covergroup aes_cg;
//     key_cp : coverpoint kt {
//       // create an automatic bin for each unique value seen, up to a limit
//       option.auto_bin_max = 64; // change as needed (limits #bins)
//     }
//     pt_cp : coverpoint pt {
//       option.auto_bin_max = 64;
//     }
//       cross key_cp, pt_cp;
//   endgroup
    
//     function new(string name = "aes_scoreboard", uvm_component parent = null);
//       super.new(name, parent);
//       aes_cg = new();
//     endfunction
  
//     function void build_phase(uvm_phase phase);
//       super.build_phase(phase);
//       analysis_export = new("analysis_export", this);
//     endfunction        
  
//     // Called automatically whenever monitor writes a transaction
//     function void write(aes_tran tr);
//   //     tr.print();
//       num_trans++;
//       // Case 1: Input transaction
//       if (tr.Ciphertext === '0) begin
//         last_key       = tr.Key;
//         last_plaintext = tr.Plaintext;
//         `uvm_info("SCOREBOARD", 
//                   $sformatf("Received INPUT: Key=%h Plaintext=%h",
//                             last_key, last_plaintext),
//                   UVM_MEDIUM)
//       end else if (tr.is_bist == 1) begin 
//   //       `uvm_info(get_type_name(), $sformatf("Entered BIST branch correctely"), UVM_LOW);
//         if (tr.Ciphertext[7:0] == 8'hc0) begin 
//           `uvm_info(get_type_name(), $sformatf("BIST passed"), UVM_MEDIUM)
//                 aes_cg.sample();
//         end else begin 
        
//           `uvm_error(get_type_name(), $sformatf("BIST failed"))
//         end 
        
        
//       end else begin
//         actual_output   = tr.Ciphertext;
//         expected_output = aes_reference_model(tr.Key, tr.Plaintext);
  
//         if (actual_output !== expected_output)
//           `uvm_error("AES_MISMATCH",
//                      $sformatf("Ciphertext mismatch!\n  Expected: %h\n  Got: %h",
//                                expected_output, actual_output))
//         else
//           `uvm_info("SCOREBOARD", "AES encryption MATCH", UVM_MEDIUM)
//           kt = tr.Key;
//           pt = tr.Plaintext;
//           aes_cg.sample();
//       end
//     endfunction
  
//     // Reference model (calls DPI-C AES)
//     function logic [127:0] aes_reference_model(
//         logic [127:0] key, logic [127:0] plaintext);
//       logic [127:0] ciphertext;
//       aes_encrypt_dpi(plaintext, key, ciphertext);
//       return ciphertext;
//     endfunction
        
        
//   //   function int classify_pattern(logic [127:0] val);
//   //     int weight = $countones(val);
//   //     if (val == 128'h0)                          return 0; // all zero
//   //     else if (val == 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF) return 1; // all one
//   //     else if (val == 128'hAA55_AA55_AA55_AA55_AA55_AA55_AA55_AA55) return 2; // alternating
//   //     else if (weight == 1)                       return 3; // single bit
//   //     else if (weight inside {[2:8]})             return 4; // low weight
//   //     else if (weight inside {[120:127]})         return 5; // high weight
//   //     else                                        return 6; // random
//   //   endfunction
//   endclass
  