class write_driver extends uvm_driver#(write_tx);
 `uvm_component_utils(write_driver)
 `NEW
 virtual interface_fifo inf;
 int j = 0;
 int k;
 function void build_phase(uvm_phase phase);
 super.build_phase(phase);
 if(!uvm_resource_db#(virtual interface_fifo)::read_by_name("ALL","TB",inf,this))
 begin
 `uvm_error("WRITE_DRIVER","Problem with the interface")
 end
  if(!uvm_resource_db#(int)::read_by_name("GOBAL","GEN",k,this)) begin
		`uvm_error("WRITE_Seq","Problem with the interface")
	 end
 endfunction

 task run_phase(uvm_phase phase);
  wait(inf.wrst_n == 1);
  forever begin 
	 seq_item_port.get_next_item(req);
    drive_tx(req);
	 //req.print();
    seq_item_port.item_done;
   end

 endtask

 //Driving inputs to the DUT
task drive_tx(write_tx tx);
		@(posedge inf.wclk);
		inf.w_en =1;
		if(!inf.full) inf.data_in = tx.data;
		else  begin
		 inf.w_en=0;
		`uvm_info("WRITE_DRIVER", $sformatf("Write_EN = %0d, FIFO is full cannot write", inf.w_en), UVM_NONE)
		end
    j++;
    if(j == k) begin
     @(posedge inf.wclk);
     
     inf.w_en =0;
     inf.data_in = 0;
     end
	 if(!inf.full) `uvm_info("WRITE_DRIVER", $sformatf("Write_EN = %0d, Data_in = %2h", inf.w_en, tx.data), UVM_NONE)
	 else  begin
		 inf.w_en=0;
		`uvm_info("WRITE_DRIVER", $sformatf("Write_EN = %0d, FIFO is full cannot write", inf.w_en), UVM_NONE)
		end
endtask

endclass
