class m_driver extends uvm_driver#(m_a_transaction);
`uvm_component_utils(m_driver)

function new (string name = null, uvm_component parent = null);
    super.new(name,parent);
endfunction 

m_a_transaction tr;
uvm_sequencer#(m_a_transaction) sqr;
virtual manager m_vif;

function void buid_phase(uvm_phase phase);
super.build_phase(phase);

assert(uvm_config_db#(virtual m_vif)):: get(this,"interface","m_vif", m_vif) else begin 
`uvm_error(get_type_name(), $sformatf("Failed to connect interface %0p", this)); end
endfunction


task run_phase (uvm_phase phase);

    forever begin 
        seq_item_port.get_next_item(tr);
        // drive_tx();
        tr.print();
        seq_item_port.item_done();
    end


endtask






endclass