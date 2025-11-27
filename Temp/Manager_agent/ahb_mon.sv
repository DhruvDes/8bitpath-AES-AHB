class ahb_mon extends uvm_monitor;

`uvm_component_utils(ahb_mon)

  function new (string name = "ahb_mon", uvm_component parent = null);
    super.new(name,parent);
endfunction 

 virtual ahb_intf s_vif;
  uvm_sequencer #(m_a_transaction) sqr;
uvm_analysis_port#(m_a_transaction) ap_port;

function void build_phase(uvm_phase phase);
super.build_phase(phase);

ap_port = new("ap_port", this);

    if (!uvm_config_db#(virtual ahb_intf)::get(this, "", "m_vif", s_vif))
      `uvm_error(get_type_name(), "Failed to connect virtual interface m_vif")
endfunction



endclass