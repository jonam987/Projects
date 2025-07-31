module asynchronous_fifo #(parameter DEPTH=512, DATA_WIDTH=8, parameter PTR_WIDTH = 8) (
  input wclk, wrst_n,
  input rclk, rrst_n,
  input winc, rinc,
  input [DATA_WIDTH-1:0] wdata,
  output reg [DATA_WIDTH-1:0] rdata,
  output reg wfull, rempty, write_error, read_error,
  output reg wr_half, rd_half // Added output signals
);

  reg [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
  reg [PTR_WIDTH:0] b_wptr, b_rptr;
  reg [PTR_WIDTH:0] g_wptr, g_rptr;

  wire [PTR_WIDTH-1:0] waddr, raddr;

  synchronizer #(PTR_WIDTH) sync_wptr (rclk, rrst_n, g_wptr, g_wptr_sync);
  synchronizer #(PTR_WIDTH) sync_rptr (wclk, wrst_n, g_rptr, g_rptr_sync);
  
  wptr_handler #(PTR_WIDTH) wptr_h(wclk, wrst_n, winc, g_rptr_sync, b_wptr, g_wptr, wfull, wr_half); // Modified call
  rptr_handler #(PTR_WIDTH) rptr_h(rclk, rrst_n, rinc, g_wptr_sync, b_rptr, g_rptr, rempty, rd_half); // Modified call
  fifo_mem fifom(wclk, winc, rclk, rinc, b_wptr, b_rptr, wdata, wfull, rempty, rdata, write_error, read_error);

endmodule



module fifo_mem #(parameter DEPTH=512, DATA_WIDTH=8, PTR_WIDTH=8) (
  input wclk, winc, rclk, rinc,
  input [PTR_WIDTH:0] b_wptr, b_rptr,
  input [DATA_WIDTH-1:0] wdata,
  input wfull, rempty,
  output reg [DATA_WIDTH-1:0] rdata,
  output reg write_error, read_error
);
  reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
  

  always_ff @(posedge wclk) begin
    write_error = 0;
    if(winc) begin
      if(wfull) begin
       write_error  = 1;
      end 
      else if (!wfull) begin
       fifo[b_wptr[PTR_WIDTH-1:0]] <= wdata;
      end
  end 
  end

  always_ff @(posedge rclk) begin
    read_error = 0;
    if(rinc) begin
     if(rempty) begin
      read_error = 1;
     end
     else if (!rempty) begin
      rdata <= fifo[b_rptr[PTR_WIDTH-1:0]];
    end
    end
  end

endmodule

module rptr_handler #(parameter PTR_WIDTH=8) (
  input rclk, rrst_n, rinc,
  input [PTR_WIDTH:0] g_wptr_sync,
  output reg [PTR_WIDTH:0] b_rptr, g_rptr,
  output reg rempty,
  output reg rd_half // Added signal
);

  reg [PTR_WIDTH:0] b_rptr_next;
  reg [PTR_WIDTH:0] g_rptr_next;
  reg rrempty;
  
  wire rd_half_calc;
  
  assign b_rptr_next = b_rptr + (rinc & !rempty); 
  assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;
  assign rrempty = (g_wptr_sync == g_rptr_next);

  // Calculate if half of the FIFO is read
  assign rd_half_calc = ((g_wptr_sync - b_rptr_next) == (1 << (PTR_WIDTH-1))); // Comparing the MSB of synchronized write and read pointers

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      b_rptr <= 0;
      g_rptr <= 0;
      rd_half <= 0;
    end else begin
      b_rptr <= b_rptr_next;
      g_rptr <= g_rptr_next;
      rd_half <= rd_half_calc;
    end
  end
   
  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) rempty <= 1;
    else rempty <= rrempty;
  end
endmodule



module synchronizer #(parameter WIDTH=8) (input clk, rst_n, [WIDTH:0] d_in, output reg [WIDTH:0] d_out);
  reg [WIDTH:0] q1;
  always_ff @(posedge clk) begin
    if(!rst_n) begin
      q1 <= 0;
      d_out <= 0;
    end
    else begin
      q1 <= d_in;
      d_out <= q1;
    end
  end
endmodule

module wptr_handler #(parameter PTR_WIDTH=8) (
  input wclk, wrst_n, winc,
  input [PTR_WIDTH:0] g_rptr_sync,
  output reg [PTR_WIDTH:0] b_wptr, g_wptr,
  output reg wfull,
  output reg wr_half // Added signal
);

  reg [PTR_WIDTH:0] b_wptr_next;
  reg [PTR_WIDTH:0] g_wptr_next;
   
  wire wwfull;
  wire wr_half_calc;
  
  assign b_wptr_next = b_wptr + (winc & !wfull);
  assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;

  // Calculate if half of the FIFO is written
  assign wr_half_calc = ((b_wptr_next - g_rptr_sync) == (1 << (PTR_WIDTH-1))); // Comparing the MSB of write and synchronized read pointers

  always@(posedge wclk or negedge wrst_n) begin
    if(!wrst_n) begin
      b_wptr <= 0; 
      g_wptr <= 0;
      wr_half <= 0;
    end else begin
      b_wptr <= b_wptr_next; 
      g_wptr <= g_wptr_next;
      wr_half <= wr_half_calc;
    end
  end
  
  always@(posedge wclk or negedge wrst_n) begin
    if(!wrst_n) wfull <= 0;
    else        wfull <= wwfull;
  end

  assign wwfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

endmodule
