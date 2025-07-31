interface interface_fifo;
  parameter DATA_WIDTH = 8;
  logic wclk, wrst_n;
  logic rclk, rrst_n;
  logic w_en, r_en;
  logic [DATA_WIDTH-1:0] data_in;
  logic [DATA_WIDTH-1:0] data_out;
  logic full, empty, write_error, read_error;
  logic wrh,rdh;


  clocking write_mon_cs@(posedge wclk);
  default input #1;
  input w_en,wrst_n,data_in,full,write_error,wrh;
  endclocking


  clocking read_mon_cs@(posedge rclk);
  default input #0;
  input r_en, rrst_n,data_out,empty,read_error,rdh;
  endclocking
endinterface 