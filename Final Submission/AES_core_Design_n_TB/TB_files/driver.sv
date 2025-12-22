import uvm_pkg::*;
`include "uvm_macros.svh"

class aes_drv extends uvm_driver#(aes_tran);
`uvm_component_utils(aes_drv)
function  new(string name = "aes_drv", uvm_component parent = null);
    super.new(name,parent);
endfunction

// uvm_sequencer#(aes_tran) sqr;
virtual aes_bist_if aes_if;


function void build_phase(uvm_phase phase);
super.build_phase(phase);
  // req = aes_tran :: type_id :: create("req");
// sqr = uvm_sequencer#(aes_tran) :: type_id :: create("sqr", this);
assert (uvm_config_db#(virtual aes_bist_if) :: get(this, "interface","aes_if", aes_if))  else begin 
`uvm_error(get_type_name(), $sformatf("%0p", this));
end
    
endfunction


task run_phase(uvm_phase phase);

forever begin 
  aes_tran req;
  seq_item_port.get_next_item(req);

    drive_dut(req);
//     req.print();
    seq_item_port.item_done();

end

endtask


task drive_dut(aes_tran req);
  // Apply reset
  
  aes_if.rst <= req.rst;
  aes_if.is_bist <= req.is_bist;
  aes_if.en_lsfr_misr <= req.en_lsfr_misr;

  if (req.rst) begin
  
    aes_if.rst <= req.rst;
    aes_if.key_in <= 8'h00;
    aes_if.d_in   <= 8'h00;  
    @(negedge aes_if.clk);
    
  
  end

  // Drive key and plaintext bytes over 16 clock cycles
  else begin
  
  aes_if.rst <= req.rst;
  aes_if.key_in <= req.Key[127:120];
  aes_if.d_in   <= req.Plaintext[127:120];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[119:112];
  aes_if.d_in   <= req.Plaintext[119:112];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[111:104];
  aes_if.d_in   <= req.Plaintext[111:104];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[103:96];
  aes_if.d_in   <= req.Plaintext[103:96];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[95:88];
  aes_if.d_in   <= req.Plaintext[95:88];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[87:80];
  aes_if.d_in   <= req.Plaintext[87:80];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[79:72];
  aes_if.d_in   <= req.Plaintext[79:72];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[71:64];
  aes_if.d_in   <= req.Plaintext[71:64];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[63:56];
  aes_if.d_in   <= req.Plaintext[63:56];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[55:48];
  aes_if.d_in   <= req.Plaintext[55:48];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[47:40];
  aes_if.d_in   <= req.Plaintext[47:40];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[39:32];
  aes_if.d_in   <= req.Plaintext[39:32];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[31:24];
  aes_if.d_in   <= req.Plaintext[31:24];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[23:16];
  aes_if.d_in   <= req.Plaintext[23:16];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[15:8];
  aes_if.d_in   <= req.Plaintext[15:8];

  @(negedge aes_if.clk);
  aes_if.key_in <= req.Key[7:0];
  aes_if.d_in   <= req.Plaintext[7:0];
  
    wait(aes_if.DONE) ; 
  @(negedge aes_if.clk); 
  aes_if.rst <= 1;
    @(negedge aes_if.clk);

  end


 

endtask

endclass
