class fpu_base_sequence extends uvm_sequence;
  `uvm_object_utils(fpu_base_sequence)
  fpu_sequence_item fpu_item;

  function new(string name="fpu_sequence");
      super.new(name);
  endfunction

endclass: fpu_base_sequence

//RESET SEQUENCE
class fpu_rst_seq extends fpu_base_sequence;

  `uvm_object_utils(fpu_rst_seq)
  fpu_sequence_item item;

  function new(string name="fpu_rst_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_name(),"Running reset sequence...",UVM_HIGH)

    item=fpu_sequence_item::type_id::create("item");
    start_item(item);
	item.constraint_mode(0);
    item.randomize() with { rst_n == 0;};
    finish_item(item);

  endtask
endclass

//MAIN SEQUENCE
class fpu_main_seq extends fpu_base_sequence;

  `uvm_object_utils(fpu_main_seq)
  fpu_sequence_item item;

  function new(string name="fpu_main_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_name(),"Running main sequence...",UVM_HIGH)

    item=fpu_sequence_item::type_id::create("item");
    start_item(item);
	item.constraint_mode(0);
	item.din_both_normal.constraint_mode(1);
    item.randomize() with { rst_n == 1;
                            dval == 1;};
    finish_item(item);
  endtask

endclass


class fpu_din1_zero_denorm_mix_seq extends fpu_base_sequence;
    `uvm_object_utils(fpu_din1_zero_denorm_mix_seq)
    
	fpu_sequence_item item;
    function new(string name="fpu_din1_zero_denorm_mix_seq"); super.new(name); endfunction
    
    task body();
        `uvm_info(get_name(),"Running Zero/Denorm Mix Test (One Special, One Normal)...", UVM_HIGH)
            
            item = fpu_sequence_item::type_id::create("item");
            start_item(item);
            
            // Disable all constraints except the target one
            item.constraint_mode(0);
            item.din1_zero_denorm_mix.constraint_mode(1);
            item.din_both_normal.constraint_mode(0); // Ensure the old 'op_normal' is off if it exists
            
            item.randomize() with { rst_n == 1; dval == 1; };
            finish_item(item);
    endtask
endclass

class fpu_din2_zero_denorm_mix_seq extends fpu_base_sequence;
    `uvm_object_utils(fpu_din2_zero_denorm_mix_seq)
    
	fpu_sequence_item item;
    function new(string name="fpu_din2_zero_denorm_mix_seq"); super.new(name); endfunction
    
    task body();
        `uvm_info(get_name(),"Running Zero/Denorm Mix Test (One Special, One Normal)...", UVM_HIGH)
            
            item = fpu_sequence_item::type_id::create("item");
            start_item(item);
            
            // Disable all constraints except the target one
            item.constraint_mode(0);
            item.din2_zero_denorm_mix.constraint_mode(1);
            item.din_both_normal.constraint_mode(0); // Ensure the old 'op_normal' is off if it exists
            
            item.randomize() with { rst_n == 1; dval == 1; };
            finish_item(item);
    endtask
endclass

class fpu_din1_inf_nan_mix_seq extends fpu_base_sequence;
    `uvm_object_utils(fpu_din1_inf_nan_mix_seq)
    
	fpu_sequence_item item;
    function new(string name="fpu_din1_inf_nan_mix_seq"); super.new(name); endfunction
    
    task body();
        `uvm_info(get_name(),"Running Inf/NaN Mix Test (One Special, One Normal)...", UVM_HIGH)
            
            item = fpu_sequence_item::type_id::create("item");
            start_item(item);
            
            item.constraint_mode(0);
            item.din1_inf_nan_mix.constraint_mode(1);
            
            item.randomize() with { rst_n == 1; dval == 1; };
            finish_item(item);
    endtask
endclass

class fpu_din2_inf_nan_mix_seq extends fpu_base_sequence;
    `uvm_object_utils(fpu_din2_inf_nan_mix_seq)
    
	fpu_sequence_item item;
    function new(string name="fpu_din2_inf_nan_mix_seq"); super.new(name); endfunction
    
    task body();
        `uvm_info(get_name(),"Running Inf/NaN Mix Test (One Special, One Normal)...", UVM_HIGH)
            
            item = fpu_sequence_item::type_id::create("item");
            start_item(item);
            
            item.constraint_mode(0);
            item.din2_inf_nan_mix.constraint_mode(1);
            
            item.randomize() with { rst_n == 1; dval == 1; };
            finish_item(item);
    endtask
endclass

// Sequence for Both Inputs = Zero
class fpu_both_zero_seq extends fpu_base_sequence;
    `uvm_object_utils(fpu_both_zero_seq)
	
	fpu_sequence_item item;
	
    function new(string name="fpu_both_zero_seq"); super.new(name); endfunction
    task body();
        `uvm_info(get_name(),"Running Both Zeros Test...", UVM_HIGH)
        item = fpu_sequence_item::type_id::create("item");
        start_item(item);
        item.constraint_mode(0);
        item.din_both_zero.constraint_mode(1);
        item.randomize() with { rst_n == 1; dval == 1; };
        finish_item(item);
    endtask
endclass

// Sequence for Both Inputs = Denormal
class fpu_both_denormal_seq extends fpu_base_sequence;
    `uvm_object_utils(fpu_both_denormal_seq)
	
	fpu_sequence_item item;
	
    function new(string name="fpu_both_denormal_seq"); super.new(name); endfunction
    task body();
        `uvm_info(get_name(),"Running Both Denormals Test...", UVM_HIGH)
        item = fpu_sequence_item::type_id::create("item");
        start_item(item);
        item.constraint_mode(0);
        item.din_both_denormal.constraint_mode(1);
        item.randomize() with { rst_n == 1; dval == 1; };
        finish_item(item);
    endtask
endclass

// Sequence for Both Inputs = Infinity
class fpu_both_inf_seq extends fpu_base_sequence;
    `uvm_object_utils(fpu_both_inf_seq)
	fpu_sequence_item item;
	
    function new(string name="fpu_both_inf_seq"); super.new(name); endfunction
    task body();
        `uvm_info(get_name(),"Running Both Infinity Test...", UVM_HIGH)
        item = fpu_sequence_item::type_id::create("item");
        start_item(item);
        item.constraint_mode(0);
        item.din_both_inf.constraint_mode(1);
        item.randomize() with { rst_n == 1; dval == 1; };
        finish_item(item);
    endtask
endclass

// Sequence for Both Inputs = NaN
class fpu_both_nan_seq extends fpu_base_sequence;
    `uvm_object_utils(fpu_both_nan_seq)
	
	fpu_sequence_item item;
	
    function new(string name="fpu_both_nan_seq"); super.new(name); endfunction
    task body();
        `uvm_info(get_name(),"Running Both NaN Test...", UVM_HIGH)
        item = fpu_sequence_item::type_id::create("item");
        start_item(item);
        item.constraint_mode(0);
        item.din_both_nan.constraint_mode(1);
        item.randomize() with { rst_n == 1; dval == 1; };
        finish_item(item);
    endtask
endclass