class ahb_agent_m extends uvm_agent;
    `uvm_component_utils(ahb_agent_m);
    
    function new (string name = null, uvm_component parent);
        super.new(name,parent);
    endfunction
    
    ahb_drv drv;
    ahb_sqr sqr;
    ahb_mon mon;
    ahb_cov cov;

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        drv = ahb_drv :: type_id :: create(drv, this);
        sqr = ahb_sqr :: type_id :: create(sqr, this);
        mon = ahb_mon :: type_id :: create(mon, this);
        cov = ahb_cov :: type_id :: create(cov, this);
       
    endfunction 

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);

        drv.seq_item_port(sqr.seq_item_export);
        mon.ap_port.connect(cov.analysis_e);
    endfunction 


endclass