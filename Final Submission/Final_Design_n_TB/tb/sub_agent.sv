class ahb_sagent extends uvm_agent;

`uvm_component_utils(ahb_sagent)
function new (string name="ahb_sagent", uvm_component parent = null);
    super.new(name, parent);
endfunction
  ahb_subor  responder; 
  ahb_mon mon;


function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	responder = ahb_subor ::type_id::create("responder", this);
	mon = ahb_mon::type_id::create("mon", this);
endfunction
endclass
