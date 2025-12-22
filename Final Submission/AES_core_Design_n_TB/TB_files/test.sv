import uvm_pkg::*;
`include "uvm_macros.svh"
    
class aes_test extends uvm_test;
    `uvm_component_utils(aes_test)
  
    aes_env env;
    uvm_sequencer#(aes_tran) sqr;
    quick_visual_test seq;
    reset_test rst_test;
    random_test_no_bist rd_t_n_b;
    bist_check bst_chk;
    rndom_testing rnd_tst;
    all_Zeros ALL_0;
    small_key_randpt smk_rndpt;
    small_pt_randkey smpt_rndk;
    highw_pt_randkey highw_pt_rkey;
    highw_key_randpt highw_key_rpt;
    final_test_for_coverage ftfc;
    high_weight_singlebit_randompt hwsbrpt;
    
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
      ALL_0 = all_Zeros :: type_id :: create("ALL_0"); 
      smk_rndpt = small_key_randpt :: type_id :: create("smk_rndpt");
      smpt_rndk = small_pt_randkey :: type_id :: create("smpt_rndk");
      highw_pt_rkey = highw_pt_randkey :: type_id :: create("highw_pt_rkey");
      highw_key_rpt = highw_key_randpt :: type_id :: create("highw_key_rpt");
      ftfc = final_test_for_coverage :: type_id :: create("final_test_for_coverage");
      hwsbrpt = high_weight_singlebit_randompt :: type_id :: create("hwsbrpt");
      
    endfunction
  
    task run_phase(uvm_phase phase);
   
      phase.raise_objection(this);
      `uvm_info(get_type_name, $sformatf("The Simulation is Running \n only ERRORS will be printed !!!"), UVM_NONE);
      repeat(2)rst_test.start(env.agent.sqr);
        
      // repeat(10)rnd_tst.start(env.agent.sqr);
      seq.start(env.agent.sqr);
      // seq.start(env.agent.sqr);
      // rd_t_n_b.start(env.agent.sqr);
      // seq.start(env.agent.sqr);
      bst_chk.start(env.agent.sqr);
      rd_t_n_b.start(env.agent.sqr);
      ALL_0.start(env.agent.sqr);
      repeat(2000) smk_rndpt.start(env.agent.sqr);
      repeat(2000) smpt_rndk.start(env.agent.sqr);
      repeat(2000) rnd_tst.start(env.agent.sqr);
      `uvm_info(get_type_name, $sformatf("Reached Half way !!!!, design is functional"), UVM_NONE);
      repeat(5000) highw_pt_rkey.start(env.agent.sqr);
      repeat(8000)  highw_key_rpt.start(env.agent.sqr);
      `uvm_info(get_type_name, $sformatf("Almost done !!!!, Trying to fill coverage atp"), UVM_NONE);
      repeat(1000) ftfc.start(env.agent.sqr);
      repeat(500) hwsbrpt.start(env.agent.sqr);
      // while (env.scb.aes_cg.get_coverage() < 40) begin 
      //   	`uvm_info(get_type_name(), $sformatf("Coverage : %f", env.scb.aes_cg.get_coverage()), UVM_MEDIUM);
      //     rnd_tst = rndom_testing :: type_id :: create("rnd_tst");
      //     rnd_tst.start(env.agent.sqr);
      
      // end
      
      #200; // let it run for a bit
      phase.drop_objection(this);
    endtask
    
    function void extract_phase(uvm_phase phase);
      super.extract_phase(phase);
      `uvm_info(get_type_name(), $sformatf("Coverage : %f", env.scb.aes_cg.get_coverage()), UVM_NONE);
      `uvm_info(get_type_name(), $sformatf("Number of transaction : %f", env.scb.num_trans), UVM_NONE);
    endfunction
  endclass