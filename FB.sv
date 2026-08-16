`timescale 1ns/1ps
module FB #(
    parameter logic [10:0] H_a  = 11'd1024,
    parameter logic [9:0]  V_a  = 10'd768,
    parameter int DATA_W = 24,
    parameter int ADDR_W = 20
)(
    input  logic                clk,
    input  logic [10:0]         h_count,
    input  logic [9:0]          v_count,
    output logic [DATA_W-1:0]   pixel
);

    localparam int DEPTH = H_a * V_a;  // 786,432

    logic [DATA_W-1:0] mem [0:DEPTH-1];
    logic [ADDR_W-1:0] addr;
   
    initial begin
        $readmemh("rick.hex", mem); // read form hex file than memory
    end
    
    assign addr = 20'(v_count * H_a) + {9'b0, h_count};

    always_ff @(posedge clk) begin
        pixel <= mem[addr];
    end

endmodule
