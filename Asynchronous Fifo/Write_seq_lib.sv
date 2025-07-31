class base_write_seq extends uvm_sequence#(write_tx);

`uvm_object_utils(base_write_seq)
`NEW_OBJ

task pre_body();
 if(starting_phase != null) begin
 	 starting_phase.raise_objection(this);
	 starting_phase.phase_done.set_drain_time(this,100);
 end
endtask

task post_body();
 if(starting_phase != null)begin
    starting_phase.drop_objection(this);
 end
endtask


endclass

class write_seq extends base_write_seq;
 int tx;
	`uvm_object_utils(write_seq)
	`NEW_OBJ
   
	 task body();
	 if(!uvm_resource_db#(int)::read_by_name("GOBAL","GEN",tx,this)) begin
		`uvm_error("WRITE_Seq","Problem with the interface")
	 end
		repeat(tx) begin
			`uvm_do(req);
    		`uvm_info("WRITE_SEQUENCE", $sformatf("Data_in = %2h", req.data), UVM_NONE)
		end
	 endtask
 endclass


