class read_coverage extends uvm_subscriber#(rd_tx);
rd_tx tx;
`uvm_component_utils(read_coverage)

covergroup rd_cg;
    // Coverpoint For Data 
    option.per_instance = 1;
    data_depth: coverpoint tx.data {
      bins depth_bins = {[0:255]}; // Assuming data depth is 8 bits as per FIFO depth analysis
      bins depth_zero = {0}; // Directly specify the value for depth 0
    }

    // Coverpoint for read enable signal to capture read operations
    read_en: coverpoint tx.r_en {
      bins read_enabled = {1};
    }

    // Coverpoint for empty signal to monitor FIFO empty status
    fifo_empty: coverpoint tx.empty {
      bins empty = {1};
      bins not_empty = {0};
    }

     // Coverpoint for tracking the reset signal	
	 reset: coverpoint tx.rrst_n {
      bins reset_not_active = {1};
    }

    // Cross coverage between read enable and FIFO empty status
    read_en_vs_fifo_empty: cross read_en, fifo_empty;



  endgroup

function new(string name= "",uvm_component parent = null);
super.new(name,parent);
rd_cg= new();
endfunction

function void write(rd_tx t);
	$cast(tx,t);
	rd_cg.sample();
endfunction


endclass