class ahb_base_seq extends uvm_sequence#(m_a_transaction);
  `uvm_object_utils(ahb_base_seq)

  function new(string name = "ahb_base_seq");
    super.new(name);
  endfunction
  rand logic read_type;
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
   m_a_transaction spec_req; 
  task body();
    
    spec_req = m_a_transaction::type_id::create("spec_req");
    start_item(spec_req);
    assert(spec_req.randomize() with { wr_rd == 1; burst == SINGLE; addr == 32'h00; });
    
    spec_req.dataQ.delete();
    spec_req.dataQ.push_back(32'h01);

    finish_item(spec_req);


 


    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == INCR8; addr == 32'h10;});

    // spec_req = m_a_transaction::type_id::create("spec_req");
    // start_item(spec_req);
    // assert(spec_req.randomize() with { wr_rd == 0; burst == SINGLE; addr == 32'h8; });
  
    // finish_item(spec_req);


    repeat(1) `uvm_do_with(req, { req.wr_rd == 0; burst == INCR4; addr == 32'h30;});
//     repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h10;});
//     repeat(1) `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h10;});
 
 
  endtask
endclass


class one_write_one_read extends ahb_base_seq;
  `uvm_object_utils(one_write_one_read)

  function new(string name = "one_write_one_read");
    super.new(name);
  endfunction

  task body();
    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h10;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h04;});
//     repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h00;});
//     repeat(1) `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h00;});
 
 
  endtask
endclass

//8 single 4single
class manual_write_all extends ahb_base_seq;
  `uvm_object_utils(manual_write_all)

  function new(string name = "manual_write_all");
    super.new(name);
  endfunction
  m_a_transaction spec_req; 
  task body();

    spec_req = m_a_transaction::type_id::create("spec_req");
    start_item(spec_req);
    assert(spec_req.randomize() with { wr_rd == 1; burst == SINGLE; addr == 32'h00; });
    
    spec_req.dataQ.delete();
    spec_req.dataQ.push_back(32'h01);

    finish_item(spec_req);

    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h10;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h14;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h18;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h1c;}); 
    
    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h20;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h24;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h28;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h2c;});
    
    
    repeat(1) `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h30;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h34;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h38;});
    repeat(1) `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h3c;});

 
  endtask
endclass


//8s read : 4I or 4s
class singwr_inc4_read extends ahb_base_seq;
  `uvm_object_utils(singwr_inc4_read)

  function new(string name = "singwr_inc4_read");
    super.new(name);
  endfunction
  m_a_transaction spec_req; 
  task body();

    spec_req = m_a_transaction::type_id::create("spec_req");
    start_item(spec_req);
    assert(spec_req.randomize() with { wr_rd == 1; burst == SINGLE; addr == 32'h00; });
    
    spec_req.dataQ.delete();
    spec_req.dataQ.push_back(32'h01);

    finish_item(spec_req);

    read_type = $urandom();

    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h10;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h14;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h18;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h1c;}); 
    
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h20;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h24;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h28;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h2c;});

    if (read_type == 1) begin

        `uvm_do_with(req, { req.wr_rd == 0; burst == INCR4; addr == 32'h30;});
    end else begin 

        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h30;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h34;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h38;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h3c;});

    end
  endtask
endclass : singwr_inc4_read



//_4Inc_4sing_4sing_or4inc
class _4Inc_4sing_4sing_or4inc extends ahb_base_seq;
  `uvm_object_utils(_4Inc_4sing_4sing_or4inc)

  function new(string name = "_4Inc_4sing_4sing_or4inc");
    super.new(name);
  endfunction
  m_a_transaction spec_req; 
  task body();

    spec_req = m_a_transaction::type_id::create("spec_req");
    start_item(spec_req);
    assert(spec_req.randomize() with { wr_rd == 1; burst == SINGLE; addr == 32'h00; });
    
    spec_req.dataQ.delete();
    spec_req.dataQ.push_back(32'h01);

    finish_item(spec_req);

    read_type = $urandom();

    `uvm_do_with(req, { req.wr_rd == 1; burst == INCR4; addr == 32'h10;});
    
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h20;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h24;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h28;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h2c;});

    if (read_type == 1) begin

        `uvm_do_with(req, { req.wr_rd == 0; burst == INCR4; addr == 32'h30;});
    end else begin 

        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h30;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h34;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h38;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h3c;});

    end
  endtask
endclass : _4Inc_4sing_4sing_or4inc



//_4Inc_4sing_4sing_or4inc
class _4Inc_4Inc_4sing_or_4inc extends ahb_base_seq;
  `uvm_object_utils(_4Inc_4Inc_4sing_or_4inc)

  function new(string name = "_4Inc_4Inc_4sing_or_4inc");
    super.new(name);
  endfunction
  m_a_transaction spec_req; 
  task body();

    spec_req = m_a_transaction::type_id::create("spec_req");
    start_item(spec_req);
    assert(spec_req.randomize() with { wr_rd == 1; burst == SINGLE; addr == 32'h00; });
    
    spec_req.dataQ.delete();
    spec_req.dataQ.push_back(32'h01);

    finish_item(spec_req);

    read_type = $urandom();

    `uvm_do_with(req, { req.wr_rd == 1; burst == INCR4; addr == 32'h10;});

    `uvm_do_with(req, { req.wr_rd == 1; burst == INCR4; addr == 32'h20;});
    
    if (read_type == 1) begin

        `uvm_do_with(req, { req.wr_rd == 0; burst == INCR4; addr == 32'h30;});
    end else begin 

        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h30;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h34;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h38;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h3c;});

    end
  endtask
endclass : _4Inc_4Inc_4sing_or_4inc



//_8Inc_4sing_or_4Inc
class _8Inc_4sing_or_4Inc extends ahb_base_seq;
  `uvm_object_utils(_8Inc_4sing_or_4Inc)

  function new(string name = "_8Inc_4sing_or_4Inc");
    super.new(name);
  endfunction
  m_a_transaction spec_req; 
  task body();

    spec_req = m_a_transaction::type_id::create("spec_req");
    start_item(spec_req);
    assert(spec_req.randomize() with { wr_rd == 1; burst == SINGLE; addr == 32'h00; });
    
    spec_req.dataQ.delete();
    spec_req.dataQ.push_back(32'h01);

    finish_item(spec_req);

    read_type = $urandom();

    `uvm_do_with(req, { req.wr_rd == 1; burst == INCR8; addr == 32'h10;});

    if (read_type == 1) begin

        `uvm_do_with(req, { req.wr_rd == 0; burst == INCR4; addr == 32'h30;});
    end else begin 

        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h30;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h34;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h38;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h3c;});

    end
  endtask
endclass : _8Inc_4sing_or_4Inc




//_4sing_4Inc_4sing_or_4Inc
class _4sing_4Inc_4sing_or_4Inc extends ahb_base_seq;
  `uvm_object_utils(_4sing_4Inc_4sing_or_4Inc)

  function new(string name = "_4sing_4Inc_4sing_or_4Inc");
    super.new(name);
  endfunction
  m_a_transaction spec_req; 
  task body();

    spec_req = m_a_transaction::type_id::create("spec_req");
    start_item(spec_req);
    assert(spec_req.randomize() with { wr_rd == 1; burst == SINGLE; addr == 32'h00; });
    
    spec_req.dataQ.delete();
    spec_req.dataQ.push_back(32'h01);

    finish_item(spec_req);

    read_type = $urandom();

    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h10;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h14;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h18;});
    `uvm_do_with(req, { req.wr_rd == 1; burst == SINGLE; addr == 32'h1c;}); 
    

    `uvm_do_with(req, { req.wr_rd == 1; burst == INCR4; addr == 32'h20;});
    
    if (read_type == 1) begin

        `uvm_do_with(req, { req.wr_rd == 0; burst == INCR4; addr == 32'h30;});
    end else begin 

        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h30;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h34;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h38;});
        `uvm_do_with(req, { req.wr_rd == 0; burst == SINGLE; addr == 32'h3c;});

    end
  endtask
endclass : _4sing_4Inc_4sing_or_4Inc




//errpkt
class errpkt extends ahb_base_seq;
  `uvm_object_utils(errpkt)

  function new(string name = "errpkt");
    super.new(name);
  endfunction
  m_a_transaction spec_req; 
  task body();

    

    spec_req = m_a_transaction::type_id::create("spec_req");
    start_item(spec_req);
    assert(spec_req.randomize() with { wr_rd == 1; burst == SINGLE; addr == 32'h00;});
    
    spec_req.dataQ.delete();
    spec_req.dataQ.push_back(32'h01);

    
    finish_item(spec_req);


    spec_req = m_a_transaction::type_id::create("spec_req");
    start_item(spec_req);
    assert(spec_req.randomize() with { !(size inside {[0:2]});
                             !(addr inside{[32'h00: 32'h3c]}); });
    // $display("size form seq %h", spec_req.size);
    // spec_req.dataQ.delete();
    // spec_req.dataQ.push_back(32'h01);

    finish_item(spec_req);

  endtask
endclass : errpkt
