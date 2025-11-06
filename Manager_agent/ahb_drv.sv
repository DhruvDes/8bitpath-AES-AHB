class m_driver extends uvm_driver#(m_a_transaction);
  `uvm_component_utils(m_driver)

  function new(string name = "m_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  m_a_transaction tr;
  uvm_sequencer#(m_a_transaction) sqr;
  virtual ahb_intf s_vif;

  // NOTE: Typo fixed: "buid_phase" → "build_phase"
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual ahb_intf)::get(this,"", "m_vif", s_vif))
      `uvm_error(get_type_name(), $sformatf("%0p", this))
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(tr);
      // drive_tx();
      tr.print();
      seq_item_port.item_done();
    end
  endtask

endclass
