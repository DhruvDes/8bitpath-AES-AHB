`include "uvm_macros.svh";
import uvm_pkg::*;

class aes_tran extends uvm_sequence_item;

function  new(string name = "aes_tran");
    super.new(name);
endfunction
// logic rst
// logic clk
rand logic [127:0] Plaintext;
rand logic [127:0] Key;
logic [7:0]key_in; 
logic [7:0]d_in;
// logic d_out
// logic d_vld
// logic DONE
rand logic is_bist
rand logic en_lsfr_misr

`uvm_object_utils_begin(aes_tran) 
uvm_field_int(Plaintext, UVM_DEFAULT)
uvm_field_int(Key, UVM_DEFAULT)
uvm_field_int(is_bist, UVM_DEFAULT)
uvm_field_int(en_lsfr_misr, UVM_DEFAULT)
`uvm_object_utils_end;


constraint bist_en_same {is_bist == en_lsfr_misr};


endclass


class aes_sequence_base extends uvm_sequencer#(aes_tran);
`uvm_object_utils_(aes_sequence_base)

function  new(string name = "aes_sequence_base");
    super.new(name);
endfunction
    
task pre_body();
    if(starting_phase != null);
    starting_phase.raise_objection(this);
endtask



task post_body();
        if(starting_phase != null);
    starting_phase.drop_objection(this);
endtask

endclass


class quick_visual_test extends uvm_sequence_base;
`uvm_object_utils_(aes_sequence_base)

function  new(string name = "quick_visual_test");
    super.new(name);
endfunction
    
task  body();

    `uvm_do_with(tran,{tran.key == 128'h000102030405060708090a0b0c0d0e0f;
                    tran.Plaintext == 128'h00112233445566778899aabbccddeeff;
    });

endtask

endclass



class aes_drv extends uvm_driver#(aes_tran);
`uvm_component_utils(aes_drv)
function  new(string name = "aes_drv", uvm_component parent = null);
    super.new(name,parent);
endfunction

uvm_sequencer#(aes_tran) sqr;
virtual aes_bist_if aes_if;


function void build_phase(uvm_phase phase);
super.build_phase(phase);

// sqr = uvm_sequencer#(aes_tran) :: type_id :: create("sqr", this);
assert (uvm_config_db#(virtual aes_bist_if) :: get(this, "interface","aes_if", aes_if))  else begin 
`uvm_error(get_type_name(), $sformatf("%0p", this));
end
    
endfunction


task run_phase(uvm_phase phase);

forever begin 
    seq_item_port.get_next_item(tran);
    drive_dut();
    tran.print();
    seq_item_port.item_done();

end

endtask


task drive_dut(); 
int j = 127,k = 120;
if (tran.is_bist == 1) begin end
// fill in bist check logic
else if (trans.is_bist == 0 && aes_if.rst == 0 && aes_if.DONE == 0) begin 

for (int i = 0; i <= 16; i++)begin
@ (negedge aes_if.clk);
 aes_if.key_in <= tran.key[j:k];
 aes_if.d_in <= tran.Plaintext[j:k];
 j = j - 8;
 k = k - 8;
end

end
endtask
endclass




module tb;


aes_bist_if aes_if():

aes_top_bist test (.rst(aes_if.rst), 
                   .clk(aes_if.clk), 
                   .key_in(aes_if.key_in), 
                   .d_in(aes_if.d_in), 
                   .d_out(aes_if.d_out), 
                   .d_vld(aes_if.d_vld), 
                   .DONE(aes_if.DONE), 
                   .is_bist(aes_if.is_bist), 
                   .en_lsfr_misr(aes_if.en_lsfr_misr));

always #5 aes_if.clk = ~aes_if.clk;  
aes_if.rst == 1;

aes_drv drv;

initial begin
    #20;
    aes_if.rst == 0;
    uvm_config_db#(aes_bist_if aes_if) :: set(null,"*.interface", "aes_if", aes_if);
    drv = new();

end



endmodule