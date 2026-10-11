`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2026 05:26:08 AM
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
    parameter DEPTH_LOG = 3
) (
    input wire clk,
    input wire rst,
    input wire [7:0] data_in,
    output reg [7:0] data_out,
    input wire wen,
    input wire ren,
    output wire data_exist,
    output reg ready,
    input wire already_read
    );

    reg [DEPTH_LOG - 1:0] tail;
    reg [DEPTH_LOG:0] len;
    reg [7:0] mem[0:(1 << DEPTH_LOG) - 1];

    reg wen_sync_1;
    reg wen_sync_2;

    reg already_written;
    reg read_data_ready;

    wire [DEPTH_LOG - 1:0] wr_addr;
    assign wr_addr = tail + len[DEPTH_LOG - 1:0];

    assign data_exist = len != 0;

    always @(posedge clk) begin
        wen_sync_1 <= wen;
        wen_sync_2 <= wen_sync_1;
    end

    always @(posedge clk) begin
        if (rst) begin
            tail <= 0;
            len <= 0;
            already_written <= 0;
            ready <= 0;
            read_data_ready <= 0;
        end
        else if (wen_sync_2 && !already_written) begin
            
            mem[wr_addr] <= data_in;
            already_written <= 1;
 
            if (len < (1 << DEPTH_LOG))
                len <= len + 1;
            else begin
                len <= len;
                tail <= tail + 1;
            end
        end
        else begin
            if (!wen_sync_2)
                already_written <= 0;
            else
                already_written <= already_written;
            
            if (ren && data_exist && !read_data_ready) begin
                read_data_ready <= 1;
                data_out <= mem[tail];
                tail <= tail + 1;
                len <= len - 1;
            end 
            else if (already_read) begin
                read_data_ready <= 0;
                ready <= 0;
            end
            else if (read_data_ready)
                ready <= 1;
        end
    end
endmodule
