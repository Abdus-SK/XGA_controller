// clk_gen.sv - 65 MHz XGA pixel clock from the Nexys A7 100 MHz oscillator (Xilinx 7-series).
//
// MMCME2_BASE primitive, so no Clocking Wizard IP is needed:
//   VCO  = 100 MHz x 9.75 / 1 = 975 MHz   (allowed range 600 - 1200 MHz for -1 speed grade)
//   CLK0 = 975 MHz / 15       = 65.000 MHz (exact XGA 1024x768 @ 60 Hz pixel clock)
// Only used for synthesis; the simulation (-DSIM) drives the pixel clock directly.

`timescale 1ns/1ps
module clk_gen (
    input  logic clk_in,     // 100 MHz
    input  logic rst,        // active high
    output logic clk_out,    // 65 MHz
    output logic locked
);
    logic clkfb, clkfb_buf, clk65;

    MMCME2_BASE #(
        .BANDWIDTH        ("OPTIMIZED"),
        .CLKIN1_PERIOD    (10.0),
        .DIVCLK_DIVIDE    (1),
        .CLKFBOUT_MULT_F  (9.75),
        .CLKOUT0_DIVIDE_F (15.0),
        .CLKOUT0_PHASE    (0.0),
        .CLKOUT0_DUTY_CYCLE (0.5),
        .STARTUP_WAIT     ("FALSE")
    ) u_mmcm (
        .CLKIN1   (clk_in),
        .CLKFBIN  (clkfb_buf),
        .CLKFBOUT (clkfb),
        .CLKFBOUTB(),
        .CLKOUT0  (clk65),
        .CLKOUT0B (), .CLKOUT1 (), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(),
        .CLKOUT3  (), .CLKOUT3B(), .CLKOUT4 (), .CLKOUT5 (), .CLKOUT6 (),
        .LOCKED   (locked),
        .PWRDWN   (1'b0),
        .RST      (rst)
    );

    BUFG u_bufg_fb  (.I(clkfb), .O(clkfb_buf));
    BUFG u_bufg_out (.I(clk65), .O(clk_out));
endmodule
