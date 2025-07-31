class fifo_test_library extends uvm_test;
 `uvm_component_utils(fifo_test_library)
 `NEW
  environment env;

 function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  env= environment::type_id::create("env",this);
 endfunction

 function void end_of_elaboration_phase(uvm_phase phase);
  uvm_top.print_topology();
 endfunction

endclass



//FIFO Write Test
class fifo_write extends fifo_test_library;
 	`uvm_component_utils(fifo_write)
	`NEW
	function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
     uvm_resource_db#(int)::set("GOBAL","GEN",5,this);
	endfunction


 task run_phase(uvm_phase phase);
   write_seq wr_seq;
 		wr_seq= write_seq::type_id::create("wr_seq",this);
 		
	    phase.raise_objection(this);
	    phase.phase_done.set_drain_time(this,100);
	    wr_seq.start(env.WR_Agent.wr_sqr);
	  
     phase.drop_objection(this);
	endtask

endclass




//FIFO Read Test
class fifo_read extends fifo_test_library;
 	`uvm_component_utils(fifo_read)
	`NEW
	function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
     uvm_resource_db#(int)::set("GOBAL","GEN",5,this);
	endfunction


 task run_phase(uvm_phase phase);
   write_seq wr_seq;
	 read_seq rd_seq;
 		wr_seq= write_seq::type_id::create("wr_seq",this);
 		rd_seq= read_seq::type_id::create("rd_seq",this);
	 
	   phase.raise_objection(this);
	   phase.phase_done.set_drain_time(this,100);
	    wr_seq.start(env.WR_Agent.wr_sqr);
	    rd_seq.start(env.RD_Agent.rd_sqr);
     phase.drop_objection(this);
	endtask

endclass



//FIFO Write & Read Test
class fifo_read_write extends fifo_test_library;
 	`uvm_component_utils(fifo_read_write)
	`NEW
	function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
     uvm_resource_db#(int)::set("GOBAL","GEN",22,this);
	endfunction


 task run_phase(uvm_phase phase);
   write_seq wr_seq;
	 read_seq rd_seq;
 		wr_seq= write_seq::type_id::create("wr_seq",this);
 		rd_seq= read_seq::type_id::create("rd_seq",this);
	 
	    phase.raise_objection(this);
	    phase.phase_done.set_drain_time(this,100);
	    wr_seq.start(env.WR_Agent.wr_sqr);
	    rd_seq.start(env.RD_Agent.rd_sqr);
     phase.drop_objection(this);
	endtask

endclass

//Testing Full Test Condition
class fifo_full extends fifo_test_library;
 	`uvm_component_utils(fifo_full)
	`NEW
	function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
   uvm_resource_db#(int)::set("GOBAL","GEN",17,this);
	endfunction


 task run_phase(uvm_phase phase);
   write_seq wr_seq;
 		wr_seq= write_seq::type_id::create("wr_seq",this);
 			 
	   phase.raise_objection(this);
	   phase.phase_done.set_drain_time(this,100);
	   wr_seq.start(env.WR_Agent.wr_sqr);
     phase.drop_objection(this);
	endtask

endclass


//Testing Full and Empty Condition
class fifo_full_empty extends fifo_test_library;
 	`uvm_component_utils(fifo_full_empty)
	`NEW
	function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
     uvm_resource_db#(int)::set("GOBAL","GEN",412,this);
     uvm_resource_db#(int)::set("GOBAL","GEN2",412,this);
	endfunction


 task run_phase(uvm_phase phase);
   write_seq wr_seq;
	 read_seq rd_seq;
 		wr_seq= write_seq::type_id::create("wr_seq",this);
 		rd_seq= read_seq::type_id::create("rd_seq",this);
	 
	   phase.raise_objection(this);
	   phase.phase_done.set_drain_time(this,100);
	    wr_seq.start(env.WR_Agent.wr_sqr);
	    rd_seq.start(env.RD_Agent.rd_sqr);
     phase.drop_objection(this);
	endtask

endclass


//simultaneos Write and Read the Data of FIFO
class simultaneous_read_write  extends fifo_test_library;
 	`uvm_component_utils(simultaneous_read_write )
	`NEW
	function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
   uvm_resource_db#(int)::set("GOBAL","GEN",20,this);
   uvm_resource_db#(int)::set("GOBAL","GEN2",20,this);
	endfunction


 task run_phase(uvm_phase phase);
   write_seq wr_seq;
	 //read_seq rd_seq;
 		wr_seq= write_seq::type_id::create("wr_seq",this);
 		//rd_seq= read_seq::type_id::create("rd_seq",this);
	 
	   phase.raise_objection(this);
	   phase.phase_done.set_drain_time(this,100);
		 fork
	    wr_seq.start(env.WR_Agent.wr_sqr);
	    rd_deq_delay;
		//rd_seq.start(env.RD_Agent.rd_sqr);
		 join
     phase.drop_objection(this);
	endtask
	
	task rd_deq_delay;
		read_seq rd_seq;
		rd_seq= read_seq::type_id::create("rd_seq",this);
		#20;
		rd_seq.start(env.RD_Agent.rd_sqr);
	endtask

endclass


