class ahb_agent_m extends uvm_agent;
  `uvm_component_utils(ahb_agent_m)

  // Constructor
  function new(string name = "ahb_agent_m", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Components
  m_driver drv;
  uvm_sequencer#(m_a_transaction) sqr;
  ahb_mon mon;
  ahb_cov cov;

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    drv = m_driver::type_id::create("drv", this);
    sqr = uvm_sequencer#(m_a_transaction)::type_id::create("sqr", this);
    mon = ahb_mon::type_id::create("mon", this);
    cov = ahb_cov::type_id::create("cov", this);
  endfunction

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    drv.seq_item_port.connect(sqr.seq_item_export);
    mon.ap_port.connect(cov.analysis_export);
  endfunction

endclass
