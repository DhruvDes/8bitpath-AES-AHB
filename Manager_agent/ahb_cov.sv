class ahb_cov extends uvm_subscriber#(m_a_transaction);
  `uvm_component_utils(ahb_cov)

  m_a_transaction trn;

  // Covergroup definition (manual sampling)
  covergroup ahb_cg;
    coverpoint trn.wr_rd;
  endgroup

  // Constructor
  function new(string name = "ahb_cov", uvm_component parent = null);
    super.new(name, parent);
    ahb_cg = new();
  endfunction

  // Proper implementation of pure virtual method 'write'
  virtual function void write(m_a_transaction t);
    $cast(trn, t);
    ahb_cg.sample();
  endfunction

endclass
