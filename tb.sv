`timescale 1ns/1ps
 module tb;
   parameter int bits = 8; 
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
    .rst_n(rst_n),
    .XGA_R        (XGA_R),        
    .XGA_G        (XGA_G),        
    .XGA_B        (XGA_B),        
    .h_sync_delay (h_sync_delay), 
    .v_sync_delay (v_sync_delay), 
    .DE_delay     (DE_delay),     
    .DE_delay1    (DE_delay1),    
    .XGA_SYNC_N   (XGA_SYNC_N),
    .h_count_delay_out(h_count_delay_out),
    .v_count_delay_out(v_count_delay_out)
    );

    //clock Gen 
    initial clk =1'b0;
    always #5 clk=~clk; // always without portlist always be running  

    initial begin
      rst_n = 1'b0;
      #100;
      rst_n = 1'b1;
    
    
    
    end
    
    always @(posedge clk) begin
    $display("time=%0t DE=%b HS=%b VS=%b RGB=%h_%h_%h DE_1=%b X_sync=%b",
             $time,
             h_sync_delay,
             v_sync_delay,
             XGA_R,
             XGA_G,
             XGA_B,
             DE_delay,
             XGA_SYNC_N,
             h_count_delay_out,
             v_count_delay_out
             );
    end

  endmodule
