`timescale 1ns/1ps
module shift_r #(
    parameter int DEPTH = 1
)(
    input  logic clk,
    input  logic rst_n,
    input  logic h_sync_in,
    input  logic v_sync_in,
    input  logic DE_in,
    input  logic [10:0] H_count_in,
    input  logic [9:0]  V_count_in,
    output logic h_sync_out,
    output logic v_sync_out,
    output logic DE_out,
    output logic [10:0] H_count_out,
    output logic [9:0]  V_count_out, 
    output logic DE_delay1
);

    logic [23:0] pipe [DEPTH];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i++)
//                pipe[i] <= 24'b110000000000000000000000;
                  pipe[i] <= {1'b1,1'b1,1'b0,11'b0,10'b0};
        end else begin
            pipe[0] <= {h_sync_in, v_sync_in, DE_in,H_count_in,V_count_in};
            for (int i = 1; i < DEPTH; i++)
                pipe[i] <= pipe[i-1];
        end
    end

 assign {h_sync_out, v_sync_out, DE_out,H_count_out,V_count_out} = pipe[DEPTH-1];
 assign DE_delay1 = pipe[0][21];
endmodule
