class fpu_test extends uvm_test;
    `uvm_component_utils(fpu_test)

  	fpu_env env; 
  	fpu_rst_seq rst_seq;
    fpu_main_seq main_seq;
	fpu_din1_zero_denorm_mix_seq din1_zero_seq;
	fpu_din2_zero_denorm_mix_seq din2_zero_seq;
	fpu_din1_inf_nan_mix_seq din1_inf_nan_seq;
	fpu_din2_inf_nan_mix_seq din2_inf_nan_seq;
	fpu_both_zero_seq both_zero_seq;
	fpu_both_denormal_seq both_denormal_seq;
	fpu_both_inf_seq both_inf_seq;
	fpu_both_nan_seq both_nan_seq;

    function new(string name="fpu_test",uvm_component parent);
        super.new(name,parent);
        `uvm_info("fpu_test", "Inside constructor of fpu_test", UVM_HIGH)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "Inside build phase", UVM_HIGH)
     	 env=fpu_env::type_id::create("env",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_name(), "Inside connect phase", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info(get_name(), "Inside run phase", UVM_HIGH)
      	
      phase.raise_objection(this);

      repeat(1) begin
		`uvm_info(get_name(), "Inside reset sequence, Resetting the DUT...", UVM_LOW)
        rst_seq=fpu_rst_seq::type_id::create("rst_seq");
        rst_seq.start(env.agent.seqr);
      end
	  
	  `uvm_info(get_name(), "Inside Main sequence, Normal numbers testing...", UVM_LOW)
      repeat(`TEST_COUNT) begin
        main_seq=fpu_main_seq::type_id::create("main_seq");
        main_seq.start(env.agent.seqr);
      end
	  
	  `uvm_info(get_name(), "Inside Zero_Denorm sequence, Zero and Denormal numbers testing for din1...", UVM_LOW)
	  repeat(`TEST_COUNT) begin
        din1_zero_seq=fpu_din1_zero_denorm_mix_seq::type_id::create("din1_zero_seq");
        din1_zero_seq.start(env.agent.seqr);
      end
	  
	  `uvm_info(get_name(), "Inside Zero_Denorm sequence, Zero and Denormal numbers testing for din2...", UVM_LOW)
	  repeat(`TEST_COUNT) begin
        din2_zero_seq=fpu_din2_zero_denorm_mix_seq::type_id::create("din2_zero_seq");
        din2_zero_seq.start(env.agent.seqr);
      end
	  
	  `uvm_info(get_name(), "Inside Inf_NaN sequence, Infinity and NaN numbers testing for din1...", UVM_LOW)
	  repeat(`TEST_COUNT) begin
        din1_inf_nan_seq=fpu_din1_inf_nan_mix_seq::type_id::create("din1_inf_nan_seq");
        din1_inf_nan_seq.start(env.agent.seqr);
      end
	  
	  `uvm_info(get_name(), "Inside Inf_NaN sequence, Infinity and NaN numbers testing for din2...", UVM_LOW)
	  repeat(`TEST_COUNT) begin
        din2_inf_nan_seq=fpu_din2_inf_nan_mix_seq::type_id::create("din2_inf_nan_seq");
        din2_inf_nan_seq.start(env.agent.seqr);
      end
	  
	  `uvm_info(get_name(), "Inside Both_Zero sequence, Both din1 and din2 are zeroes...", UVM_LOW)
	  repeat(`TEST_COUNT) begin
        both_zero_seq=fpu_both_zero_seq::type_id::create("both_zero_seq");
        both_zero_seq.start(env.agent.seqr);
      end
	  
	  `uvm_info(get_name(), "Inside Both_Denormal sequence, Both din1 and din2 are denormals...", UVM_LOW)
	  repeat(`TEST_COUNT) begin
        both_denormal_seq=fpu_both_denormal_seq::type_id::create("both_denormal_seq");
        both_denormal_seq.start(env.agent.seqr);
      end
	  
	  `uvm_info(get_name(), "Inside Both_Inf sequence, Both din1 and din2 are Infinity...", UVM_LOW)
	  repeat(`TEST_COUNT) begin
        both_inf_seq=fpu_both_inf_seq::type_id::create("both_inf_seq");
        both_inf_seq.start(env.agent.seqr);
      end
	  
	  `uvm_info(get_name(), "Inside Both_NaN sequence, Both din1 and din2 are NaN...", UVM_LOW)
	  repeat(`TEST_COUNT) begin
        both_nan_seq=fpu_both_nan_seq::type_id::create("both_nan_seq");
        both_nan_seq.start(env.agent.seqr);
      end
	    
      //wait(env.scb.test_cnt==`TEST_COUNT);

      phase.drop_objection(this);
        
    endtask

endclass: fpu_test

