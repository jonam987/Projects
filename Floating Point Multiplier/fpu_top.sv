`timescale 1ns/1ns
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "fpu_def.sv"



module top;

    bit clk=0;

    fpu_if top_if(clk);

  fpu_sp_mul dut (
    	.clk      (top_if.clk      ),
      .rst_n    (top_if.rst_n    ),
      .din1     (top_if.din1     ),
      .din2     (top_if.din2     ),
      .dval     (top_if.dval     ),
      .result   (top_if.result   ),
      .rdy      (top_if.rdy      )
  );

//clock generation
    initial forever #1 clk=~clk;

 	initial begin
      uvm_config_db #(virtual fpu_if) :: set(null,"*","fpu_vif",top_if);
      `uvm_info("TOP","Configured database for interface...",UVM_LOW)
    end

    initial begin
      run_test();
    end
  
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;
  end

endmodule
