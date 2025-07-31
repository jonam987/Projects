class read_monitor extends uvm_monitor;
`uvm_component_utils(read_monitor)
 rd_tx tx;
 uvm_analysis_port#(rd_tx) ap_port;

`NEW
 virtual interface_fifo inf;
 
function void build_phase(uvm_phase phase);
  super.build_phase(phase);
 if(!uvm_resource_db#(virtual interface_fifo)::read_by_name("ALL","TB",inf,this)) // Reterving the Interface
  begin
   `uvm_error("read_monitor","Problem with the interface")
  end
   ap_port= new("ap_port",this);
endfunction

//Collecting the Data From the Interface
 task run_phase(uvm_phase phase);
   forever begin
		@(inf.read_mon_cs);
      if(inf.read_mon_cs.r_en==1)begin
		tx = new();
      tx.rrst_n=inf.read_mon_cs.rrst_n;
	  tx.r_en=inf.read_mon_cs.r_en;
      tx.empty=inf.read_mon_cs.empty;
	  tx.rdh =inf.read_mon_cs.rdh;
      tx.read_error=inf.read_mon_cs.read_error;
		 repeat(2) @(posedge inf.rclk);
		 tx.data=inf.read_mon_cs.data_out;
		   ap_port.write(tx);
		if(!tx.empty) `uvm_info("Read_Monitor",$psprintf("MON is doing READ in data=%0h",tx.data),UVM_NONE)
		else `uvm_info("Read_Monitor", $sformatf("FIFO is empty"), UVM_NONE)
		
		if(tx.rdh) `uvm_info("Read_Monitor",$psprintf("FIFO is half full"),UVM_NONE)
	 
     end 
	end
 endtask


endclass
