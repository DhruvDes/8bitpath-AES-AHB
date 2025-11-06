class ahb_base_seq extends uvm_sequence#(m_a_transaction);
  `uvm_object_utils(ahb_base_seq)

  function new(string name = "ahb_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    if (starting_phase != null)
      starting_phase.raise_objection(this);
  endtask
  
  task post_body();
    if (starting_phase != null)
      starting_phase.drop_objection(this);
  endtask
endclass



class ahb_wr_rd_seq extends ahb_base_seq;
  `uvm_object_utils(ahb_wr_rd_seq)

  function new(string name = "ahb_wr_rd_seq");
    super.new(name);
  endfunction

  task body();
    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; });
    repeat(1) `uvm_do_with(req, { req.wr_rd == 0; });
  endtask
endclass
