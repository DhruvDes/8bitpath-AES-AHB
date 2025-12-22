class m_driver extends uvm_driver#(m_a_transaction);
  `uvm_component_utils(m_driver)

  function new(string name = "m_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  m_a_transaction tr;
  uvm_sequencer#(m_a_transaction) sqr;
  virtual ahb_if m_if;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ahb_if)::get(this,"interface","ahb_vif",m_if))
      `uvm_error(get_type_name(), $sformatf("%p", this))
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      seq_item_port.get_next_item(tr);
      // tr.print();
     drive_tx(tr);


      seq_item_port.item_done();
    end
  endtask

  task drive_tx(m_a_transaction req);
  int beats;
  beats = req.length;

  // Start from IDLE
  m_if.m_cb.htrans <= IDLE;
  m_if.m_cb.hsel   <= 1;
//   m_if.hwdata <= '0;

  // Wait for reset released
  wait (m_if.hrstn == 1);
  // wait (m_if.hreadyOut == 1);

  // ----------------------------------------
  // First address phase (NONSEQ)
  // ----------------------------------------
  @( m_if.m_cb);
  wait (m_if.m_cb.hreadyOut == 1 || m_if.hready);

  m_if.m_cb.hsel   <= 1;
  m_if.m_cb.hready   <= 1;
  m_if.m_cb.hburst <= req.burst;
  m_if.m_cb.hsize  <= req.size;
  m_if.m_cb.hwrite <= req.wr_rd;
  m_if.m_cb.haddr  <= req.addr;
  m_if.m_cb.htrans <= NONSEQ;

  // NOTE: no hwdata yet; first data comes next cycle

  // ----------------------------------------
  // Data & subsequent beats
  // ----------------------------------------
  for (int beat = 0; beat < beats; beat++) begin
    // This edge = data phase of current beat, address phase of next beat
    @(m_if.m_cb);
    wait (m_if.m_cb.hreadyOut == 1);

    // ---- DATA PHASE for this beat ----
    if (req.wr_rd) begin
      // WRITE: drive data for this beat
      m_if.m_cb.hwdata <= req.dataQ.pop_front();
    end
    else begin
      // READ: capture data for this beat
      req.dataQ.push_back(m_if.hrdata);
      req.resp = m_if.hresp;
      if (m_if.hresp == 1);
        // `uvm_error("AHB_TX","subor Error response")
    end

    // ---- ADDRESS PHASE for next beat or IDLE ----
    if (beat < beats - 1) begin
      // More beats to go: SEQ for next beat
      req.addr += (1 << req.size);
      m_if.m_cb.haddr  <= req.addr;
      m_if.m_cb.htrans <= SEQ;
      // keep hsel = 1 here
    end
    else begin
   
      // m_if.htrans <= IDLE;
   
    end
  end

 
  // @(posedge m_if.hclk);
  // optionally wait(hreadyOut) again if you want to be strict
  wait (m_if.m_cb.hreadyOut == 1);

  m_if.m_cb.hsel   <= 1;
  m_if.m_cb.htrans <= IDLE;
  // m_if.hwdata <= '0;   
  endtask

endclass

//GPT GARBAGE//
// class m_driver extends uvm_driver#(m_a_transaction);
  
//   `uvm_component_utils(m_driver)

//   function new(string name = "m_driver", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   m_a_transaction tr;
//   uvm_sequencer#(m_a_transaction) sqr;
//   virtual ahb_if m_if;

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     if (!uvm_config_db#(virtual ahb_if)::get(this,"interface","ahb_vif",m_if))
//       `uvm_error(get_type_name(), $sformatf("%p", this))
//   endfunction

//   task run_phase(uvm_phase phase);
//     super.run_phase(phase);
//     forever begin
//       seq_item_port.get_next_item(tr);
//       // tr.print();
//       drive_tx(tr);
//       seq_item_port.item_done();
//     end
//   endtask

//   task drive_tx(m_a_transaction req);
//   int beats;
//   beats = req.length;

//   // Start from IDLE
//   m_if.htrans <= IDLE;
//   m_if.hsel   <= 1;
// //   m_if.hwdata <= '0;

//   // Wait for reset released
//   wait (m_if.hrstn == 1);

//   // ----------------------------------------
//   // First address phase (NONSEQ)
//   // ----------------------------------------
//   // wait (m_if.hreadyOut == 1);
//   @(posedge m_if.hclk);


//   m_if.hsel   <= 1;
//   m_if.hready   <= 1;
//   m_if.hburst <= req.burst;
//   m_if.hsize  <= req.size;
//   m_if.hwrite <= req.wr_rd;
//   m_if.haddr  <= req.addr;
//   m_if.htrans <= NONSEQ;

//   // NOTE: no hwdata yet; first data comes next cycle
//   @(posedge m_if.hclk);
//   wait (m_if.hreadyOut == 1);
//   // ----------------------------------------
//   // Data & subsequent beats
//   // ----------------------------------------
//   for (int beat = 0; beat < beats; beat++) begin
//     // This edge = data phase of current beat, address phase of next beat
//     wait (m_if.hreadyOut == 1);
//     @(posedge m_if.hclk);


//     // ---- DATA PHASE for this beat ----
//     if (req.wr_rd) begin
//       // WRITE: drive data for this beat
//       m_if.hwdata <= req.dataQ.pop_front();
//     end
//     else begin
//       // READ: capture data for this beat
//       req.dataQ.push_back(m_if.hrdata);
//       req.resp = m_if.hresp;
//       if (m_if.hresp == 1)
//         `uvm_error("AHB_TX","subor Error response")
//     end

//     // ---- ADDRESS PHASE for next beat or IDLE ----
//     if (beat < beats - 1) begin
//       // More beats to go: SEQ for next beat
//       req.addr += (1 << req.size);
//       m_if.haddr  <= req.addr;
//       m_if.htrans <= SEQ;
//       // keep hsel = 1 here
//     end
//     else begin
//       // Last beat: next **address** is IDLE,
//       // but KEEP hsel = 1 for this last data phase
//       m_if.htrans <= IDLE;
//       // don't touch hsel here
//     end
//   end

//   // ----------------------------------------
//   // One extra cycle to drop HSEL after last data
//   // ----------------------------------------
//   @(posedge m_if.hclk);
//   // optionally wait(hreadyOut) again if you want to be strict
//   // wait (m_if.hreadyOut == 1);

//   m_if.hsel   <= 1;
//   m_if.htrans <= IDLE;
// //   m_if.hwdata <= '0;   // optional
// endtask


// endclass
