class environment extends uvm_env;

`uvm_component_utils(environment)
`NEW

 wrt_agent WR_Agent;
 rd_agent RD_Agent; 
 async_sb Sc_rd;

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  WR_Agent = wrt_agent::type_id::create("WR_Agent",this); 
  RD_Agent = rd_agent::type_id::create("RD_Agent",this);
  Sc_rd   =  async_sb::type_id::create("Sc_rd",this);
endfunction

function void connect_phase(uvm_phase phase);
  WR_Agent.wr_mon.ap_port.connect(Sc_rd.ap_imp_wr);	//Connecting Write Monitor and Scoreboard
  RD_Agent.rd_mon.ap_port.connect(Sc_rd.ap_imp_rd); //Connectiong Read Monitor and Scoreboard

endfunction

endclass
