`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2026 09:13:30 AM
// Design Name: 
// Module Name: counter
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


module counter
(
    input  wire       clk,
    input  wire       rst,
    input  wire       load,
    input  wire [3:0] data_in,
    input  wire       en,
    input  wire       up_down,
    output reg  [3:0] count
);
    always @(posedge clk, posedge rst) begin
        if (rst)
            count <= 0;
        else
            if (load)
                count <= data_in;
            else if (en)
                if (up_down)
                    count <= count + 1;
                else
                    count <= count - 1;
    end
endmodule

