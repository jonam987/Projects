class fpu_sequence_item extends uvm_sequence_item;

    rand logic rst_n;
    rand logic [31:0] din1;
    rand logic [31:0] din2;
    rand logic dval;
    logic [31:0] result;
    logic rdy;

    // Internal rand variable to control the operational mode
    rand bit [1:0] op_mode; 

    `uvm_object_utils_begin (fpu_sequence_item)
        `uvm_field_int (rst_n, UVM_BIN)
        `uvm_field_int (din1, UVM_HEX)
        `uvm_field_int (din2, UVM_HEX)
        `uvm_field_int (dval, UVM_BIN)
        `uvm_field_int (result, UVM_HEX)
        `uvm_field_int (rdy, UVM_BIN)
    `uvm_object_utils_end

    function new(string name="fpu_sequence_item");
        super.new(name);
    endfunction

    function bit is_normal(logic [31:0] din);
        return (din[30:23] != 8'd0 && din[30:23] != 8'd255);
    endfunction
    // E_raw = 0
    function bit is_zero_denorm(logic [31:0] din);
        return (din[30:23] == 8'd0);
    endfunction
    // E_raw = 255
    function bit is_inf_nan(logic [31:0] din);
        return (din[30:23] == 8'd255);
    endfunction
    
    // =======================================================
    // I. MIXED SPECIAL CASES (One input is Special, the other is Normal)
    // =======================================================
    
    // 1. Single Zero/Denormal: Any one input is 0 or Denormal (E_raw = 0)
    constraint din1_zero_denorm_mix {
        
            // Case A: din1 is Zero/Denorm AND din2 is Normal
			din2[30:23] != 8'd0;
			din2[30:23] != 8'd255;
        // Ensure that if E_raw=0, fraction is randomized to be 0 (Zero) or non-0 (Denormal)
        din1[22:0] dist { 0:/50,
							[1:$]:/50};
							
		din1[30:23] == 8'd0;
				
    }
	
	constraint din2_zero_denorm_mix {
        
            // Case A: din1 is Zero/Denorm AND din2 is Normal
			din1[30:23] != 8'd0;
			din1[30:23] != 8'd255;
        // Ensure that if E_raw=0, fraction is randomized to be 0 (Zero) or non-0 (Denormal)
        din2[22:0] dist { 0:/50, [1:$]:/50};
							
		din2[30:23] == 8'd0;
				
    }
	
    
    // 2. Single Inf/NaN: Any one input is Infinity or NaN (E_raw = 255)
    constraint din1_inf_nan_mix {
            // Case A: din1 is Inf/NaN AND din2 is Normal
            
			din1[30:23] == 8'd255;
			din1[22:0] dist { 0:/50 , [1:$]:/50};
			din2[30:23] != 8'd0;
			din2[30:23] != 8'd255;
			
    }
	
	constraint din2_inf_nan_mix {
            // Case A: din1 is Inf/NaN AND din2 is Normal
            
		din2[30:23] == 8'd255;
		din2[22:0] dist { 0:/50 , [1:$]:/50};
		din1[30:23] != 8'd0;
		din1[30:23] != 8'd255;
			
    }
    
    // =======================================================
    // II. PURE SPECIAL CASES (Both inputs are the same Special Type)
    // =======================================================
    
    // 3. Both Zeros: Both inputs must be zero (E_raw = 0, Fraction = 0)
    constraint din_both_zero {
        din1[30:23] == 8'd0; din1[22:0] == '0; // din1 = 0
        din2[30:23] == 8'd0; din2[22:0] == '0; // din2 = 0
    }
    
    // 4. Both Denormals: Both inputs must be denormal (E_raw = 0, Fraction != 0)
    constraint din_both_denormal {
        din1[30:23] == 8'd0; din1[22:0] != '0; // din1 = Denormal
        din2[30:23] == 8'd0; din2[22:0] != '0; // din2 = Denormal
    }
    
    // 5. Both Infinity: Both inputs must be infinity (E_raw = 255, Fraction = 0)
    constraint din_both_inf {
        din1[30:23] == 8'd255; din1[22:0] == '0; // din1 = Inf
        din2[30:23] == 8'd255; din2[22:0] == '0; // din2 = Inf
    }
    
    // 6. Both NaN: Both inputs must be NaN (E_raw = 255, Fraction != 0)
    constraint din_both_nan {
        din1[30:23] == 8'd255; din1[22:0] != '0; // din1 = NaN
        din2[30:23] == 8'd255; din2[22:0] != '0; // din2 = NaN
    }
    
    // 7. Original Normal Case (Renamed for clarity)
    constraint din_both_normal {
		din1[30:23] != 8'd0;
		din1[30:23] != 8'd255;
		din2[30:23] != 8'd0;
		din2[30:23] != 8'd255;
    }
    
endclass