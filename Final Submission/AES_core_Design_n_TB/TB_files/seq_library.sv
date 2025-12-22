import uvm_pkg::*;
`include "uvm_macros.svh"
    
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
      // `uvm_do_with(req,{req.Key == 128'h000102030405060708090a0b0c0d0e0f;
      //                   req.Plaintext == 128'h00112233445566778899aabbccddeeff;
      //                   req.rst == 0;
      //                     is_bist == 0;
      //   });
      `uvm_do_with(req,{req.Key == 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
      req.Plaintext == 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
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
      `uvm_do_with(req, {
        req.rst == 0;
        req.is_bist dist {0 := 99};
    
    
        req.Key dist { 
          128'h1                                       := 25,
          128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 25,
          128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA := 25,
          [128'h0000_0000_0000_0000_0000_0000_0000_0000 :
           128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF] := 25
        };
    
        req.Plaintext dist { 
          128'h1                                       := 25,
          128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 25,
          128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA := 25,
          [128'h0000_0000_0000_0000_0000_0000_0000_0000 :
           128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF] := 25
        };
      })
    //   `uvm_do_with(req, {rst== 0;})
    endtask
    endclass
    
    class all_Zeros extends uvm_sequence_base;
      `uvm_object_utils(all_Zeros)
    
      function new(string name = "all_Zeros");
        super.new(name);
      endfunction
        
      aes_tran req;
    
    task body();
      req = aes_tran::type_id::create("req");
      `uvm_do_with(req, {
        req.rst == 0;
        req.is_bist dist {0 := 99};
        req.Key == 128'h00;  
        req.Plaintext == 128'h00;  })
    //   `uvm_do_with(req, {rst== 0;})
    endtask
    endclass
    

    class small_key_randpt extends uvm_sequence_base;
      `uvm_object_utils(small_key_randpt)
    
      function new(string name = "small_key_randpt");
        super.new(name);
      endfunction
        
      aes_tran req;
    
    task body();
      req = aes_tran::type_id::create("req");
      `uvm_do_with(req, {
        req.rst == 0;
        req.Key dist {28'h3 := 10,
        128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA := 10,
        128'h0000_0000_0000_0000_0000_0000_0000_0000 := 10,
        // 128'hFFFF_0000_0000_0000_0000_0000_0000_0000 := 10,
        // 128'h1111_1111_1111_1111_1111_1111_1111_1111 := 10,
        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10};

        req.Plaintext dist {128'h5 := 10,
                            128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA := 10,
                            128'h0000_0000_0000_0000_0000_0000_0000_FFFF := 10,
                            [128'h0000_0000_0000_0000_0000_0000_0000_0000 :
                            128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF] := 10};  })
    //   `uvm_do_with(req, {rst== 0;})
    endtask
    endclass



    class small_pt_randkey extends uvm_sequence_base;
      `uvm_object_utils(small_pt_randkey)
    
      function new(string name = "small_pt_randkey");
        super.new(name);
      endfunction
        
      aes_tran req;
    
    task body();
      req = aes_tran::type_id::create("req");
      `uvm_do_with(req, {
        req.rst == 0;
		 req.is_bist == 0;
        req.Plaintext dist {28'h3 := 10,
        128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA := 10,
        128'h0000_0000_0000_0000_0000_0000_0000_0000 := 10,
        // 128'hFFFF_0000_0000_0000_0000_0000_0000_0000 := 10,
        // 128'h1111_1111_1111_1111_1111_1111_1111_1111 := 10,
        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10}; 

        req.Key dist {      128'h5 := 10,
                            128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA := 10,
                            128'h0000_0000_0000_0000_0000_0000_0000_FFFF := 10,
                            [128'h0000_0000_0000_0000_0000_0000_0000_0000 :
                            128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF] := 10};  })
    //   `uvm_do_with(req, {rst== 0;})
    endtask
    endclass




    class highw_pt_randkey extends uvm_sequence_base;
      `uvm_object_utils(highw_pt_randkey)
    
      function new(string name = "highw_pt_randkey");
        super.new(name);
      endfunction
        
      aes_tran req;
    
    task body();
      req = aes_tran::type_id::create("req");
      `uvm_do_with(req, {
        req.rst == 0;
		req.is_bist == 0;
        req.Key dist {
        128'h0EFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10,
        128'hFFFF_FFFF_1DFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10,
        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10,
        128'hFFFF_FFFF_FFFF_FFFF_FFFF_3BFF_FFFF_FFFF := 10,
        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FF4A := 10,
        128'h1 := 10,
        128'h7 := 10,
        128'h00 := 10,
        128'h5555_5555_5555_5555_5555_5555_5555_5555 := 10,
        128'hFFFF_FFFF_FFFF_FFFF_2CFF_FFFF_FFFF_FFFF := 10

          }; 

        req.Plaintext dist {      128'h7 := 10,
                            128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA := 10,
                     
                            128'h0000_0000_0000_0000_0000_0000_0000_0000 := 10,
                            128'hFFFF_FFFF_FFFF_FFFF_2CFF_FFFF_FFFF_FFFF := 10,
                            128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10,
                    
                            128'h01 := 10}; })
                            // [128'h0000_0000_0000_0000_0000_0000_0000_0000 :
                            // 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF] := 10};  })
    //   `uvm_do_with(req, {rst== 0;})
    endtask
    endclass




    class highw_key_randpt extends uvm_sequence_base;
      `uvm_object_utils(highw_key_randpt)
    
      function new(string name = "highw_key_randpt");
        super.new(name);
      endfunction
        
      aes_tran req;
    
    task body();
      req = aes_tran::type_id::create("req");
      `uvm_do_with(req, {
        req.rst == 0;
		req.is_bist == 0;
        req.Plaintext dist {
        128'h0EFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10,
        128'hFFFF_FFFF_1DFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10,
        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10,
        128'hFFFF_FFFF_FFFF_FFFF_FFFF_3BFF_FFFF_FFFF := 10,
        128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FF4A := 10,
        128'h1 := 10,
        128'h7 := 10,
        128'h00 := 10,
        128'h5555_5555_5555_5555_5555_5555_5555_5555 := 10,
        128'hFFFF_FFFF_FFFF_FFFF_2CFF_FFFF_FFFF_FFFF := 10,
        [128'h0000_0000_0000_0000_0000_0000_0000_0001 : 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE ] := 1

          }; 

        req.Key dist {      128'h7 := 10,
                            128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA := 10,
                     
                            128'h0000_0000_0000_0000_0000_0000_0000_0000 := 10,
                            128'hFFFF_FFFF_FFFF_FFFF_2CFF_FFFF_FFFF_FFFF := 10,
                            128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF := 10,
                            [128'h0000_0000_0000_0000_0000_0000_0000_0001 : 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE ] := 1,
                            128'h01 := 20}; })
                            // [128'h0000_0000_0000_0000_0000_0000_0000_0000 :
                            // 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF] := 10};  })
    //   `uvm_do_with(req, {rst== 0;})
    endtask
    endclass



//highly directed testcase
	class final_test_for_coverage extends uvm_sequence_base;
		`uvm_object_utils(final_test_for_coverage)
	  
		function new(string name = "final_test_for_coverage");
		  super.new(name);
		endfunction
		  
		aes_tran req;
	  
	  task body();
		req = aes_tran::type_id::create("req");
		`uvm_do_with(req, {
		  req.rst == 0;
		  req.is_bist == 0;
		  req.Plaintext dist {
		  128'hFFFF_FFFF_FFFF_FFFF_FFFF_3BFF_FFFF_FFFF := 10,
		  128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FF4A := 10,
		  128'h1 := 20
			}; 
  
		  req.Key dist {     
						
							 [128'h0000_0000_0000_0000_0000_0000_0000_0001 : 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE ] := 1,
							  128'h01 := 10}; })
			

	  endtask
	  endclass


	

	  	class high_weight_singlebit_randompt extends uvm_sequence_base;
		`uvm_object_utils(high_weight_singlebit_randompt)
	  
		function new(string name = "high_weight_singlebit_randompt");
		  super.new(name);
		endfunction
		  
		aes_tran req;
	  
	  task body();
		req = aes_tran::type_id::create("req");
		`uvm_do_with(req, {
		  req.rst == 0;
		  req.is_bist == 0;
		  req.Key dist {
		  128'hFFFF_FFFF_FFFF_FFFF_FFFF_3BFF_FFFF_FFFF := 10,
		  128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FF4A := 10,
		  128'h1 := 20
			}; 
  
		  req.Plaintext dist {     
						
							 [128'h0000_0000_0000_0000_0000_0000_0000_0001 : 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE ] := 1,
							  128'h01 := 10}; })
			

	  endtask
	  endclass