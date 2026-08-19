`timescale 1ns/1ps
 module tb;
   parameter logic [3:0] bits = 4'd8; 
   logic[bits-1:0]XGA_R;
   logic[bits-1:0]XGA_B;
   logic[bits-1:0]XGA_G;
		
   logic rst_n;
   logic clk;

   logic h_sync_delay;
   logic v_sync_delay;
   logic DE_delay;
   logic DE_delay1;
   logic XGA_SYNC_N;
   logic [10:0] h_count_delay_out;
   logic [9:0]  v_count_delay_out;

   
  XGA_controller DUT (
    .clk(clk),
    .rst_n(rst)
  );



endmodule
