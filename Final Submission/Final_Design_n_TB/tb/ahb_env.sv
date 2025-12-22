class ahb_env extends uvm_env;
    `uvm_component_utils(ahb_env);
    
  	function new (string name = "ahb_env", uvm_component parent);
        super.new(name,parent);
    endfunction
    
    ahb_agent_m Magnt;
  	ahb_sagent sagnt;
 	ahb_scoreboard scb;

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

      Magnt = ahb_agent_m :: type_id :: create("Magnt", this);
      //sagnt = ahb_sagent :: type_id :: create("sagnt", this);
      scb  = ahb_scoreboard ::  type_id :: create("scb", this);
    endfunction 
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

   Magnt.mon.ap.connect(scb.mon_imp);
  endfunction


endclass