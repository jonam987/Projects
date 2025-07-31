class write_monitor extends uvm_monitor;
`uvm_component_utils(write_monitor)
 write_tx tx;
 uvm_analysis_port#(write_tx) ap_port;

 `NEW
 virtual interface_fifo inf;
 
 function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  ap_port= new("ap_port",this);
  if(!uvm_resource_db#(virtual interface_fifo)::read_by_name("ALL","TB",inf,this)) //Reterving the Interface
  begin
   `uvm_error("WRITE_MON","Problem with the interface")
  end
 endfunction

 //Getting the Data from Interface
  task run_phase(uvm_phase phase);
   forever begin
     @(inf.write_mon_cs);
     if(inf.write_mon_cs.w_en == 1)  begin
        tx = new();
        tx.wrst_n = inf.write_mon_cs.wrst_n;
        tx.full = inf.write_mon_cs.full;
		tx.wrh = inf.write_mon_cs.wrh;
        tx.write_error= inf.write_mon_cs.write_error;
		tx.w_en = inf.write_mon_cs.w_en;
		tx.data = inf.write_mon_cs.w_en? inf.write_mon_cs.data_in:1'b0;
		ap_port.write(tx);
		if(!tx.full) `uvm_info("Write_Monitor",$psprintf("MON is doing WRITE at data=%0h",tx.data),UVM_NONE)
		else `uvm_info("Write_Monitor", $sformatf(" FIFO is full"), UVM_NONE)
		
		if(tx.wrh) `uvm_info("Write_Monitor",$psprintf("FIFO is half full"),UVM_NONE)
   end
   end
  endtask


endclass