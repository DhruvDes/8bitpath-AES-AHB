class ahb_base_seq extends uvm_sequence#(ahb_tx);
	`uvm_object_utils(ahb_base_seq)
	function new(string name = ""); 
		super.new(name);
	endfunction

	task pre_body();
		if (starting_phase != null) begin
			starting_phase.raise_objection(this);
		end
	endtask
	task post_body();
		if (starting_phase != null) begin
			starting_phase.drop_objection(this);
		end
	endtask
endclass



class ahb_wr_rd_seq extends ahb_base_seq;
`uvm_component_obj(ahb_wr_rd_seq)

function new (string name);
    super.new(name);
endfunction

task body();
    repeat(1) `uvm_do_with(req, {req.wr_rd == 1;});
    repeat(1) `uvm_do_with(req, {req.wr_rd == 0;}); 
endtask

endclass