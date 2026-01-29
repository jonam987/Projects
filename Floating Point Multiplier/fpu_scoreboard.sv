class fpu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fpu_scoreboard)
  
  uvm_analysis_imp #(fpu_sequence_item, fpu_scoreboard) scb_port;

  
  fpu_sequence_item item[$];
  f`
  int test_cnt=0;
  int test_valid=0;
  int test_invalid=0;  


  covergroup fpu_mul_coverage;
    option.per_instance = 1;
    
    // --- 1. Input Classification Coverpoints ---
    
    // Classification of din1 based on its exponent (30:23)
    din1_class : coverpoint s_item.din1[30:23] {
        // Exponent 8'h00 is Zero or Denormal
        bins zero_denorm = {8'h00}; 
        // Exponent 8'h01 to 8'hFE is Normal (most common case)
        bins normal      = {[8'h01:8'hFE]};
        // Exponent 8'hFF is Special (Inf or NaN)
        bins special     = {8'hFF};  
    }

    // Classification of din2 based on its exponent (30:23)
    din2_class : coverpoint s_item.din2[30:23] {
        bins zero_denorm = {8'h00}; 
        bins normal      = {[8'h01:8'hFE]};
        bins special     = {8'hFF};
    }

    // Cross-coverage of all input classifications (e.g., Normal x Denormal, Zero x Inf)
    cross_class : cross din1_class, din2_class;
	
	result_class: coverpoint s_item.result[30:23] {
		bins zero_denorm = {8'h00}; 
        // Exponent 8'h01 to 8'hFE is Normal (most common case)
        bins normal      = {[8'h01:8'hFE]};
        // Exponent 8'hFF is Special (Inf or NaN)
        bins special     = {8'hFF};  
    }
    

  endgroup: fpu_mul_coverage
    

  
  function new(string name = "fpu_scoreboard", uvm_component parent);
    super.new(name, parent);
    `uvm_info("SCB_CLASS", "Inside Constructor!", UVM_HIGH)
     fpu_mul_coverage = new();
  endfunction: new
  

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCB_CLASS", "Build Phase!", UVM_HIGH)
    scb_port=new("scb_port",this);

  endfunction: build_phase
  
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SCB_CLASS", "Connect Phase!", UVM_HIGH)
   
  endfunction: connect_phase
  
  function void write (fpu_sequence_item rx_item);
    item.push_front(rx_item);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever  begin
      s_item=fpu_sequence_item::type_id::create("s_item");
      wait((item.size() != 0));
      s_item=item.pop_front();
//       s_item.print();
      fpu_mul_coverage.sample();
      compare(s_item);
      
      test_cnt++;
    end
  endtask
  
  function void compare(fpu_sequence_item item);
    logic [31:0] ex_res;
    ex_res=floatOperations(item.din1,item.din2);
	if((item.din1[30:23]==8'hFF && item.din1[22:0]!=0) || (item.din2[30:23]==8'hFF && item.din2[22:0]!=0)) begin
		if(item.result[30:23] != ex_res[30:23] && item.result[22:0] == 0) begin
			$display("din1 = %0h  din2 = %0h \nactual = %0h \nexpected = NaN",item.din1,item.din2,item.result);
		end
		else test_valid++;  
	end
	
    else if (ex_res==item.result) begin
	  //`uvm_info(get_name,$sformatf("din1 = %0h  din2 = %0h \nactual = %0h \nexpected = %0h",item.din1,item.din2,item.result,ex_res),UVM_LOW)
      `uvm_info(get_name,$sformatf("[%0d/%0d] Test Passed",test_cnt,`TEST_COUNT),UVM_HIGH)
      test_analysis(item,ex_res,0);
      test_valid++;
    end
    
    else begin
      `uvm_error(get_name,$sformatf("[%0d/%0d] Test failed",test_cnt,`TEST_COUNT))
      test_analysis(item,ex_res,1);
      test_invalid++;
    end
  endfunction
  
  function void test_analysis(fpu_sequence_item item, logic [31:0] ex_res,bit flag);
    if(flag & (get_report_verbosity_level()>=UVM_MEDIUM)) begin
      $display("--------------------------------------------------------------------------------");
      $display("din1 = %0h  din2 = %0h \nactual = %0h \nexpected = %0h",item.din1,item.din2,item.result,ex_res);
    end
      ///$display("--------------------------------------------------------------------------------");
  endfunction
  
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_name(),$sformatf("Total tests: %0d",test_cnt),UVM_LOW)
    `uvm_info(get_name(),$sformatf("Passed tests: %0d",test_valid),UVM_LOW)
    `uvm_info(get_name(),$sformatf("Failed  tests: %0d",test_invalid),UVM_LOW)
  endfunction
endclass