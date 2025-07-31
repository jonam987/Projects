class read_driver extends uvm_driver#(rd_tx);
`uvm_component_utils(read_driver)
`NEW
 virtual interface_fifo inf;

 function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_resource_db#(virtual interface_fifo)::read_by_name("ALL","TB",inf,this))
  begin
   `uvm_error("Read_DRIVER","Problem with the interface")
  end
 endfunction

 task run_phase(uvm_phase phase);
  wait(inf.rrst_n == 1);
   forever begin
    seq_item_port.get_next_item(rsp);
    // rsp.print();
    drive_tx(rsp);
	  seq_item_port.item_done;
   end
 endtask

 //Driving imports to the DUT and geting outputs from the DUT
task drive_tx(rd_tx tx);
		 @(posedge inf.rclk);
		 inf.r_en =1;
		 @(posedge inf.rclk);
		 tx.data = inf.data_out;
		 if(!inf.empty) `uvm_info("READ_DRIVER", $sformatf("Read_EN = %0d, Data_out = %2h ", inf.r_en, tx.data), UVM_LOW)
		 else `uvm_info("READ_DRIVER", $sformatf("FIFO is empty"), UVM_NONE)
		 inf.r_en =0;
		 @(posedge inf.rclk);
endtask

endclass