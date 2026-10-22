`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2026 11:49:05 AM
// Design Name: 
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo #(
    parameter WIDTH=32,
    parameter ADDR_WIDTH=4
    ) (
    input clk,
    input arstn,
    input [WIDTH - 1:0] din,
    output [WIDTH - 1:0] dout,
    input wvalid,
    input rready,
    output rvalid
    );

    localparam DEPTH = (1 << ADDR_WIDTH);

    reg [WIDTH - 1:0] mem[0:DEPTH - 1];
    reg [ADDR_WIDTH:0] len;
    reg [ADDR_WIDTH - 1:0] tail;

    wire [ADDR_WIDTH - 1:0] waddr = tail + len;

    assign rvalid = len != 0;

    assign dout = mem[tail];

    wire read = rvalid && rready;
    wire write_and_read = wvalid && read;
    wire write_not_full = wvalid && (len != DEPTH);
    wire write_full = wvalid && (len == DEPTH);

    always @(posedge clk) begin
        if (wvalid)
            mem[waddr] <= din;
    end

    always @(posedge clk or negedge arstn) begin
        if (!arstn) begin
            tail <= 0;
            len <= 0;
        end
        else if (write_and_read)
            tail <= tail + 1;
        else if (write_not_full)
            len <= len + 1;
        else if (write_full)
            tail <= tail + 1;
        else if (read) begin
            tail <= tail + 1;
            len <= len - 1;
        end
    end
endmodule
