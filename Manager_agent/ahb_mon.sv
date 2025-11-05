class ahb_mon extends uvm_monitor

`uvm_component_utils(ahb_mon)

function new (string name = null, uvm_component parent = null);
    super.new(name,parent);
endfunction 

virtual manager m_vif;
uvm_sequencer #(m_a_transaction);
uvm_analysis_port#(m_a_transaction) ap_port;

function void buid_phase(uvm_phase phase);
super.build_phase(phase);

ap_port = new("ap_port", this);

assert(uvm_config_db#(virtual manager)):: get(this,"interface","m_vif", m_vif) else begin 
`uvm_error(get_type_name(), $sformatf("Failed to connect interface %0p", this)); end
endfunction



endclass