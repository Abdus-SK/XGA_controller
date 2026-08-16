//U1 = PLL
//U2 = Shiftregisters
//U3 = FB

`define SIM
`timescale 1ns/1ps
module XGA_controller #(
   parameter logic [3:0]  bits = 4'd8,
   parameter logic [10:0] H_t  = 11'd1344,
   parameter logic [10:0] H_a  = 11'd1024,
   parameter logic [10:0] H_s  = 11'd136,
   parameter logic [10:0] H_bp = 11'd160,
   parameter logic [10:0] H_fp = 11'd24,
    
   parameter logic [9:0]  V_t  = 10'd806,
   parameter logic [9:0]  V_a  = 10'd768,
   parameter logic [9:0]  V_s  = 10'd6,
   parameter logic [9:0]  V_bp = 10'd29,
   parameter logic [9:0]  V_fp = 10'd3
)(
   output logic[bits-1:0]XGA_R,
   output logic[bits-1:0]XGA_B,
   output logic[bits-1:0]XGA_G,
		
   input logic rst_n,
   input logic clk,

   output logic h_sync_delay,
   output logic v_sync_delay,
   output logic DE_delay,
   output logic DE_delay1,
   output logic XGA_SYNC_N,
   output logic [10:0] h_count_delay_out,
   output logic [9:0]  v_count_delay_out
);


   logic h_sync;
   logic v_sync;
   logic DE;

   wire XGA_clk;
   logic [23:0] pixeldata;
   logic locked;
   logic [10:0] h_count;
   logic [9:0] v_count;
   logic [10:0] h_count_delay;
   logic [9:0] v_count_delay;
   
 
   wire mrst_n;
   parameter int PIPE_DEPTH = 2;
   assign mrst_n=rst_n & locked;
   assign XGA_SYNC_N= 1'b1;


`ifdef SIM
   assign XGA_clk = clk; 
   assign locked  = 1'b1; 
   //assign mrst_n  = rst_n;
`else
   //PLL INSTANTIATION
   clock_0002 u1(
	.refclk   (clk),        //  refclk.clk
	.rst      (~rst_n),      //   reset.reset
	.outclk_0 (XGA_clk),    // outclk0.clk
	.locked   (locked)      //  locked.export
); 
`endif

 //Counter
   always_ff @(posedge XGA_clk or negedge mrst_n)begin:A1
      if(!mrst_n) begin
		   h_count<=0;
			v_count<=0;
		 end else begin
            if(h_count==H_t-1)begin 
				   h_count<=0;
				   if(v_count==V_t-1)
				      v_count<=0;
                  else v_count<=v_count+1; 
                  end
                  else h_count<=h_count+1; end end:A1			

 typedef enum logic [1:0] {Ha,Hfp,Hs,Hbp} H_states;
        H_states HCS,HNS;
 typedef enum logic [1:0] {Va, Vfp, Vs, Vbp} V_states; 
        V_states VCS,VNS;

 //sequential block
   always_ff@(posedge XGA_clk or negedge mrst_n)begin
      if (!mrst_n)
			HCS<=Ha;
       else 
			HCS<=HNS;
       end

   always_ff@(posedge XGA_clk or negedge mrst_n)begin
       if(!mrst_n)
           VCS<=Va;
      else begin
	    if(h_count==H_t-1)
           VCS <= VNS;
    end
    end


 //FSM combinational block
 always_comb begin:A2
    case(HCS)
        Ha:   h_sync= 1'b1;
        Hfp:  h_sync= 1'b1;
        Hs:   h_sync= 1'b0;
        Hbp:  h_sync= 1'b1;
        default: h_sync= 1'b1;
    endcase
 end:A2
 
 
 always_comb begin
    case(VCS)
        Va:   v_sync=1'b1;
        Vfp:  v_sync=1'b1;
        Vs:   v_sync=1'b0;
        Vbp:  v_sync=1'b1;
        default:v_sync=1'b1;
    endcase
 end


 //FSM Combinational block
 always_comb begin
  case(HCS)
      Ha:
			HNS=(h_count==H_a-1)? Hfp : Ha;
      Hfp:
			HNS=(h_count==H_a+H_fp-1)? Hs : Hfp;
      Hs:
			HNS=(h_count==H_a+H_fp+H_s-1)? Hbp : Hs;
      Hbp:
			HNS=(h_count==H_a+H_fp+H_s+H_bp-1)? Ha : Hbp;
	   default: HNS=Ha;
  endcase
 end

 always_comb begin
  case (VCS)
      Va:
         VNS=(v_count==V_a-1)? Vfp:Va;
      Vfp:
         VNS=(v_count==V_a+V_fp-1)?Vs:Vfp;
      Vs:
         VNS=(v_count==V_a+V_fp+V_s-1)?Vbp:Vs;
      Vbp:
         VNS=(v_count==V_a+V_fp+V_s+V_bp-1)?Va:Vbp;
      default:VNS=Va;
  endcase
 end
 
 //shift registers 
 shift_r #(.DEPTH(PIPE_DEPTH)) u2 (
   .clk         (XGA_clk),
   .rst_n       (mrst_n),
   .h_sync_in   (h_sync),
   .v_sync_in   (v_sync),      
   .DE_in       (DE),
   .h_sync_out  (h_sync_delay),
   .v_sync_out  (v_sync_delay),
   .DE_out      (DE_delay),
   .H_count_in  (h_count),
   .V_count_in  (v_count),
   .H_count_out (h_count_delay), 
   .V_count_out (v_count_delay),
   .DE_delay1   (DE_delay1)
 );

 FB u3(
    .clk     (XGA_clk),
    .h_count (h_count),
    .v_count (v_count),
    .pixel   (pixeldata)
   );

 //DRIVING OUTPUT
 assign DE = (VCS==Va) && (HCS==Ha);
 assign h_count_delay_out = h_count_delay;
 assign v_count_delay_out = v_count_delay;

 always_ff@(posedge XGA_clk or negedge mrst_n) begin
    if(!mrst_n)begin
      XGA_R<=0;
      XGA_G<=0;
      XGA_B<=0;
 end 
	 else if(DE_delay1) begin
      XGA_R<=pixeldata[23:16];
      XGA_G<=pixeldata[15:8];
      XGA_B<=pixeldata[7:0];
 end
	 else begin
      XGA_R<=0;
      XGA_G<=0;
      XGA_B<=0;
 end
 end
 //VGA DRIVING SIGNALS LOGIC END gang what we doing here fuckng hell what mate

endmodule
