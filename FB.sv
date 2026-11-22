`timescale 1ns/1ps
module FB #(
    parameter logic [10:0] H_a      = 11'd1024,       // active width on screen
    parameter logic [9:0]  V_a      = 10'd768,        // active height on screen
    parameter int          BITS     = 4,              // bits per colour
    parameter int          IMG_W    = 512,            // stored picture width  = 1024 / 2
    parameter int          IMG_H    = 384,            // stored picture height = 768 / 2
    parameter int          ADDR_W   = 18,             // address width: 2^18 = 262,144 >= 196,608
    parameter              MEM_FILE = "rick444.mem"
)(
    input  logic              clk,
    input  logic [10:0]       h_count,
    input  logic [9:0]        v_count,
    input  logic              test_pattern,
    output logic [3*BITS-1:0] pixel                   // 12 bits: R[11:8] G[7:4] B[3:0]
);

    localparam int DEPTH = IMG_W * IMG_H;                            // 196,608 pixels
    localparam logic [ADDR_W-1:0] ROW_LEN = IMG_W;                   // 512, as an 18-bit number

    (* rom_style = "block" *) logic [3*BITS-1:0] mem [0:DEPTH-1];   // the picture
    logic [ADDR_W-1:0] addr;
    logic [3*BITS-1:0] img_q, bar_q, bar;
    logic              sel_q;

    initial $readmemh(MEM_FILE, mem);

    wire              active = (h_count < H_a) && (v_count < V_a);
    wire [ADDR_W-1:0] row    = {{(ADDR_W-9){1'b0}},  v_count[9:1]};   // = v_count / 2
    wire [ADDR_W-1:0] col    = {{(ADDR_W-10){1'b0}}, h_count[10:1]};  // = h_count / 2
    assign addr = active ? row * ROW_LEN + col : '0;

    always_comb begin
        if (h_count == 0 || h_count == H_a-1 || v_count == 0 || v_count == V_a-1)
            bar = '1;                                     // white border (all 12 bits = 1)
        else case (h_count[9:7])                          // which 128-pixel-wide stripe
            3'd0: bar = 12'hFFF;  // white     3'd1: bar = 12'hFF0;  // yellow
            3'd2: bar = 12'h0FF;  // cyan      3'd3: bar = 12'h0F0;  // green
            3'd4: bar = 12'hF0F;  // magenta   3'd5: bar = 12'hF00;  // red
            3'd6: bar = 12'h00F;  // blue      default: bar = 12'h000; // black
        endcase
    end

    always_ff @(posedge clk) begin
        img_q <= mem[addr];            // picture pixel, 1 clock later
        bar_q <= bar;                  // bar pixel, also 1 clock later
        sel_q <= test_pattern;
    end
    assign pixel = sel_q ? bar_q : img_q;
 
endmodule
