// nexys_a7_top.sv - XGA (1024x768 @ 60 Hz) controller on the Digilent Nexys A7-100T.
//
//   CLK100MHZ  -> XGA_controller (makes the 65 MHz pixel clock internally)
//   CPU_RESETN -> reset (active low button)
//   SW[0]      -> 0 = image from block RAM, 1 = colour-bar test pattern
//   VGA_R/G/B[3:0], VGA_HS, VGA_VS -> VGA connector (4 bits per colour)
//   LED[0]     -> SW[0] state, LED[15] -> heartbeat (~1 Hz, shows the design is running)

`timescale 1ns/1ps
module nexys_a7_top (
    input  logic       CLK100MHZ,
    input  logic       CPU_RESETN,
    input  logic [0:0] SW,
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B,
    output logic       VGA_HS,
    output logic       VGA_VS,
    output logic [15:0] LED
);

    /* verilator lint_off UNUSEDSIGNAL */
    logic        de, de1, sync_n;      // not used on this board (no video DAC)
    logic [10:0] hc;
    logic [9:0]  vc;
    /* verilator lint_on UNUSEDSIGNAL */

    XGA_controller u_xga (
        .clk               (CLK100MHZ),
        .rst_n             (CPU_RESETN),
        .test_pattern      (SW[0]),
        .XGA_R             (VGA_R),
        .XGA_G             (VGA_G),
        .XGA_B             (VGA_B),
        .h_sync_delay      (VGA_HS),
        .v_sync_delay      (VGA_VS),
        .DE_delay          (de),
        .DE_delay1         (de1),
        .XGA_SYNC_N        (sync_n),
        .h_count_delay_out (hc),
        .v_count_delay_out (vc)
    );

    // heartbeat on the 100 MHz clock: proves the bitstream is running even with no monitor
    logic [26:0] beat;
    always_ff @(posedge CLK100MHZ) beat <= beat + 1'b1;

    assign LED[0]    = SW[0];
    assign LED[14:1] = '0;
    assign LED[15]   = beat[26];

endmodule
