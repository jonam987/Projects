class wrt_agent extends uvm_agent;
`uvm_component_utils(wrt_agent)
 write_driver wr_drv;
 write_sqr wr_sqr;
 write_coverage wr_cov;
 write_monitor wr_mon;
 `NEW

 function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  wr_drv= write_driver::type_id::create("wr_drv",this);
  wr_sqr= write_sqr::type_id::create("wr_sqr",this);
  wr_mon= write_monitor::type_id::create("wr_mon",this);
  wr_cov= write_coverage::type_id::create("wr_cov",this);
 endfunction

 function void connect_phase(uvm_phase phase);
  wr_drv.seq_item_port.connect(wr_sqr.seq_item_export); //Connecting Write Driver to Writer Sequencer
  wr_mon.ap_port.connect(wr_cov.analysis_export); //Connecting Write Monitor to Write Coverage
 endfunction



endclass
