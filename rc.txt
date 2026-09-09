`timescale 1ns/1ps
module tb;

 logic clk = 0;
 logic rst_n = 0;
 logic h_sync_delay, v_sync_delay, DE_delay, DE_delay1, XGA_SYNC_N;
 logic [7:0] XGA_R, XGA_G, XGA_B;
 logic [10:0] h_count_delay_out;
 logic [9:0]  v_count_delay_out;

 XGA_controller dut (
    .clk(clk), .rst_n(rst_n),
    .h_sync_delay(h_sync_delay), .v_sync_delay(v_sync_delay),
    .DE_delay(DE_delay), .DE_delay1(DE_delay1),
    .XGA_SYNC_N(XGA_SYNC_N),
    .XGA_R(XGA_R), .XGA_G(XGA_G), .XGA_B(XGA_B),
    .h_count_delay_out(h_count_delay_out),
    .v_count_delay_out(v_count_delay_out)
    );

    // 25 MHz-ish pixel clock -- exact freq doesn't matter for a functional sim
 always #10 clk = ~clk;

 integer fd;
 initial begin
    fd = $fopen("frame0.ppm", "w");
    $fwrite(fd, "P3\n1024 768\n255\n");   // PPM header: ASCII RGB, 8-bit max

    rst_n = 0;
    repeat (5) @(posedge clk);
    rst_n = 1;

    // run long enough for one full frame: H_t * V_t cycles, plus pipeline latency margin
    repeat (1344*806 + 10) @(posedge clk) begin
      if (DE_delay)
        $fwrite(fd, "%0d %0d %0d\n", XGA_R, XGA_G, XGA_B);
      end

    $fclose(fd);
    $display("Frame dump complete.");
    $finish;
    end

endmodule
