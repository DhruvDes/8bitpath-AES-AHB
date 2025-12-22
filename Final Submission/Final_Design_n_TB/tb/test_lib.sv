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
  one_write_one_read orow;
  manual_write_all mwa;
  singwr_inc4_read singlewr_inc4rd;
  function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    rw_seq = ahb_wr_rd_seq :: type_id :: create("rw_seq");
    orow = one_write_one_read:: type_id :: create("orow");
    mwa = manual_write_all :: type_id :: create("mwa");
    singlewr_inc4rd = singwr_inc4_read :: type_id :: create ("singlewr_inc4rd");
    endfunction 
  
  
  
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    // repeat(4)rw_seq.start(env.Magnt.sqr);
//     orow.start(env.Magnt.sqr); 
    //  mwa.start(env.Magnt.sqr);
    repeat(10)singlewr_inc4rd.start(env.Magnt.sqr);
    
    #100;
    phase.drop_objection(this);  
  endtask
  	
  
  
endclass




class manual_rw extends ahb_base_test;
  
  `uvm_component_utils(manual_rw);
    
  function new (string name = "manual_rw", uvm_component parent);
        super.new(name,parent);
    endfunction
    

  manual_write_all mwa;
   
  function void build_phase (uvm_phase phase);
        super.build_phase(phase);

    mwa = manual_write_all :: type_id :: create("mwa");
    endfunction 
  
  
  
 
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
 

      mwa.start(env.Magnt.sqr);
    #100;
    phase.drop_objection(this);  
  endtask
  	
  
endclass : manual_rw



class complete_test extends ahb_base_test;
  
  `uvm_component_utils(complete_test);
    
  function new (string name = "complete_test", uvm_component parent);
        super.new(name,parent);
    endfunction
    

  manual_write_all           _8sing_4sing;
  singwr_inc4_read          _8sing_4incr;
  _4Inc_4sing_4sing_or4inc  _4i4s4si;
  _4Inc_4Inc_4sing_or_4inc  _4i4i4si;
  _8Inc_4sing_or_4Inc       _8i4si;
  _4sing_4Inc_4sing_or_4Inc _4s4i4si;
  errpkt err;

  logic [2:0] what_test;
   
  function void build_phase (uvm_phase phase);
        super.build_phase(phase);

    _8sing_4sing =  manual_write_all         :: type_id :: create("_8sing_4sing");
    _8sing_4incr =  singwr_inc4_read         :: type_id :: create("_8sing_4incr");
    _4i4s4si     = _4Inc_4sing_4sing_or4inc  :: type_id :: create("_4i4s4si");   
    _4i4i4si     = _4Inc_4Inc_4sing_or_4inc  :: type_id :: create("_4i4i4si");
    _8i4si       = _8Inc_4sing_or_4Inc       :: type_id :: create("_8i4si");
    _4s4i4si     = _4sing_4Inc_4sing_or_4Inc :: type_id :: create("_4s4i4si");
    err          = errpkt :: type_id :: create("err");
    endfunction 
  
  
  
 
  task run_phase(uvm_phase phase);
    int i;
    phase.raise_objection(this);
    
    `uvm_info(get_type_name(), $sformatf("Tb is running please be patient, \n only error resp will show up \n or reduce the number in the repeat"),UVM_NONE);
    `uvm_info(get_type_name(), $sformatf("\n Purposely done in order to prevent system from crashing"),UVM_NONE);
    repeat(100_000) begin
      what_test = $urandom;
      i += 1;
      // `uvm_info(get_type_name(), $sformatf("test number: %d, test type : %d",i, what_test),UVM_NONE);
      case (what_test)
        3'd0:_8sing_4sing.start(env.Magnt.sqr);
        3'd1:_8sing_4incr.start(env.Magnt.sqr);
        3'd2:_4i4s4si    .start(env.Magnt.sqr);
        3'd3:_4i4i4si    .start(env.Magnt.sqr);
        3'd4:_8i4si      .start(env.Magnt.sqr);
        3'd5:_4s4i4si    .start(env.Magnt.sqr);
      default : begin 
        err.start(env.Magnt.sqr);
      end
      endcase
    end

    // err.start(env.Magnt.sqr);
    // _4s4i4si    .start(env.Magnt.sqr);
   
 


    #100;
 
    phase.drop_objection(this);  
  endtask
  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Coverage : %f", env.Magnt.cov.ahb_cg.get_coverage()), UVM_NONE);
    `uvm_info(get_type_name(), $sformatf("Coverage : %f", env.Magnt.cov. write_against_burst_Typs.get_coverage()), UVM_NONE);
    `uvm_info(get_type_name(), $sformatf("Coverage : %f", env.Magnt.cov.read_against_burst_Typs.get_coverage()), UVM_NONE);
  endfunction
  
endclass : complete_test