
class ahb_scoreboard extends uvm_component;
  `uvm_component_utils(ahb_scoreboard)

  // Analysis export
  uvm_analysis_imp #(reply_pkt, ahb_scoreboard) mon_imp;


  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_imp = new("mon_imp", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

logic [127:0] key_reg, pt_reg, ct_reg_rcv, ct_reg;
logic [31:0] ct_reg_corr[4];
  function void write(reply_pkt tr); 
    // `uvm_info(get_type_name(), "Scoreboard Got called by Monitor",UVM_MEDIUM );

  // tr.print();

if (tr.hresp != 1) begin
  key_reg = {tr.key[0], tr.key[1], tr.key[2], tr.key[3]};
  pt_reg  = {tr.pt[0], tr.pt[1], tr.pt[2], tr.pt[3]};
  ct_reg_rcv  = {tr.ct[0], tr.ct[1], tr.ct[2], tr.ct[3]};
   aes_encrypt_dpi(pt_reg, key_reg, ct_reg);
  // `uvm_info(get_type_name(), $sformatf("key: %h" , key_reg),UVM_MEDIUM );
  // `uvm_info(get_type_name(), $sformatf("pt : %h", pt_reg),UVM_MEDIUM );
  // `uvm_info(get_type_name(), $sformatf("ct : %h", ct_reg),UVM_MEDIUM );

   ct_reg_corr[3] = ct_reg[127:96]; 
   ct_reg_corr[0] = ct_reg[95:64];
   ct_reg_corr[1] = ct_reg[63:32];
   ct_reg_corr[2] = ct_reg[31:0];
   

  for (int i = 0; i < 3; i++)begin 

    // $display("ct_reg_corr[%h] : %h --- %h", i, ct_reg_corr[i], tr.ct[i]);
    if (ct_reg_corr[i] == tr.ct[i])begin
      // `uvm_info(get_type_name(),$sformatf("Values, correct"), UVM_MEDIUM);
    end else begin 
      `uvm_error(get_type_name(), $sformatf("values dont match"))
    end
  end 



end // if(!tr.hresp)

if(tr.hresp == 1) begin 

  // tr.print();
  if ((tr.haddr >= 32'h00 && tr.haddr <= 32'h3C) && tr.hsize == 2 && tr.hburst inside{3'b0, 3'b011, 3'b101}) begin 
    `uvm_error(get_type_name, "error issued incorrectly");
  end else begin 
    // `uvm_info(get_type_name(), "Error issued correctley", UVM_MEDIUM);
  end 

end
   
  endfunction

endclass

// key: 12ce297a22b6008fc95950d9efd58804                      

// pt : a7b7021e1dc1e98eb8572c9c115250cf 