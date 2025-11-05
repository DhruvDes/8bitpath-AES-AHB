class ahb_cov extends uvm_subscriber#(m_a_transaction);

`uvm_component_utils(ahb_cov)

m_a_transaction trn; 
covergroup ahb_cg@(ahb_e);
 coverpoint  trn.wr_rd;
endgroup 

function new (string name = null, uvm_component parent = null);
    super.new(name,parent);
    ahb_cg = new();
endfunction 

virtual function void Writer(T t);
$cast(trn, t);
ahb_cg.sample();
endfunction




endclass