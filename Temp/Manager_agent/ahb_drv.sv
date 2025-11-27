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
//       drive_tx();
      tr.print();
      seq_item_port.item_done();
    end
  endtask
    
    int j;
 task drive_tx(m_a_transaction req);
   wait (s_vif.hresetn == 0);

  arb_phase(req);
  addr_phase(req);

  // Assuming req.len defines burst length
   for (int i = 0; i < req.length - 1; i++) begin
    fork
      addr_phase(req, 1);
      data_phase(req,i);
      j = i;
    join
  end

   data_phase(req, j);
endtask


task arb_phase(m_a_transaction req);

endtask


task addr_phase(m_a_transaction req = null, bit itr = 0);
  @(negedge s_vif.hclk);
  s_vif.haddr  = req.addr;
  s_vif.hwrite = req.wr_rd;
  s_vif.hburst = req.burst;

//   req.addr = req.addr + 4;
//   if (req.addr > req.high_addr)
//     req.addr = req.base_addr;

  if (itr == 0) begin
    s_vif.htrans = NONSEQ;
  end
  else begin
    s_vif.htrans = SEQ;
    
  end
  wait(s_vif.hready == 1);
  req.addr = req.addr + 2**req.size;
endtask


    task data_phase(m_a_transaction req, bit i);
  wait(s_vif.hready == 1);

  if (req.wr_rd) begin 
    s_vif.hwdata = req.dataQ[i];
  end
  else begin
    `uvm_info("AHB_DRV", $sformatf("Read data = %h", s_vif.hrdata), UVM_LOW);
  end
endtask
    
    

endclass