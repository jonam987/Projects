class write_coverage extends uvm_subscriber#(write_tx);
write_tx tx;

`uvm_component_utils(write_coverage)



  covergroup wr_cg;
    option.per_instance = 1;
    
    // Cover points
    cp_data: coverpoint tx.data {
      bins valid_data[64] = {[0:255]};
    }
    cp_w_en: coverpoint tx.w_en {     
      bins enabled = {1'b1};
    }
    cp_wrst_n: coverpoint tx.wrst_n {
      //bins reset = {1'b0};
      bins no_reset = {1'b1};
    }
    cp_full: coverpoint tx.full {
      //bins full = {1'b1};
      bins not_full = {1'b0};
    }
    cp_write_error: coverpoint tx.write_error {
      //bins error = {1'b1};
      bins no_error = {1'b0};
       
    }

    

    // Cross coverage
    cross_burst_idle: cross cp_data, cp_w_en; 

  endgroup

function new(string name= "",uvm_component parent = null);
  super.new(name,parent);
  wr_cg= new();
endfunction



function void write(write_tx t);
	$cast(tx,t);
	wr_cg.sample();
endfunction
endclass