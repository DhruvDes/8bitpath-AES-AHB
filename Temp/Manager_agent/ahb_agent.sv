class ahb_agent extends uvm_agent;
	int master_no;
	string master_no_l;
	`uvm_component_utils_begin(ahb_agent)
		`uvm_field_int(master_no, UVM_ALL_ON)
	`uvm_component_utils_end
	ahb_driver drv;
	 uvm_sequencer #(m_a_transaction) sqr;
	//ahb_monitor mon;
	//ahb_coverage cov;
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv = ahb_driver::type_id::create("drv", this);
		sqr = ahb_sequencer::type_id::create("sqr", this);
	endfunction
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction
endclass
