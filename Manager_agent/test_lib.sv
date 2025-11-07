class ahb_base_test extends uvm_test;
    `uvm_component_utils(ahb_base_test);
    
  function new (string name = "ahb_base_test", uvm_component parent);
        super.new(name,parent);
    endfunction
    
    ahb_env env;

  
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        env = ahb_env :: type_id :: create("env", this);
      	
      
    endfunction 
  
	

  
    function  void end_of_elaboration_phase(uvm_phase phase);

    `uvm_info(get_type_name(), this.sprint(), UVM_NONE)
        
    endfunction

endclass



class r_w_1_test extends ahb_base_test;
  
  `uvm_component_utils(r_w_1_test);
    
  function new (string name = "r_w_1_test", uvm_component parent);
        super.new(name,parent);
    endfunction
    
  ahb_wr_rd_seq rw_seq;
  
  function void build_phase (uvm_phase phase);
        super.build_phase(phase);
      	rw_seq = ahb_wr_rd_seq :: type_id :: create("rw_seq", this);
      
    endfunction 
  
  
  
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    rw_seq.start(env.Magnt.sqr);
    phase.drop_objection(this);  
  endtask
  	
  
  
endclass