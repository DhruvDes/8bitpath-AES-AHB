class ahb_env extends uvm_env;
    `uvm_component_utils(ahb_env);
    
    function new (string name = null, uvm_component parent);
        super.new(name,parent);
    endfunction
    
    ahb_agent_m Magnt;

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        Magnt = ahb_agent_m :: type_id :: create("Magnt", this);
    endfunction 


endclass