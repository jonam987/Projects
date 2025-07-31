class base_read_seq extends uvm_sequence#(rd_tx);

`uvm_object_utils(base_read_seq)
`NEW_OBJ

//Raising the  Objection && Setting the Drain Time
task pre_body();
 if(starting_phase != null) begin
 	 starting_phase.raise_objection(this);
	 starting_phase.phase_done.set_drain_time(this,100);
 end
endtask

//Drop Objection
task post_body();
 if(starting_phase != null)begin
  starting_phase.drop_objection(this);
	end
endtask


endclass

class read_seq extends base_read_seq;
 int tx;
	`uvm_object_utils(read_seq)
	`NEW_OBJ

	 task body();
 	 if(!uvm_resource_db#(int)::read_by_name("GOBAL","GEN2",tx,this)) begin
		`uvm_error("Read_Seq","Problem with the interface")
	 end
		repeat((tx+1)) begin
			`uvm_do(req); 
    		`uvm_info("READ_SEQUENCE", $sformatf("Data_out = %2h", req.data), UVM_NONE)
		end
	 endtask
 endclass



