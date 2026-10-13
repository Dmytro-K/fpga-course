`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 07:11:13 AM
// Design Name: 
// Module Name: task14_tb
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


module task14_tb;
    reg clk;
    reg nrst;

    task14 dut(.clk(clk), .nrst(nrst));

    localparam PERIOD = 10 * 10;
    localparam PERIOD_HALF = PERIOD / 2;
    localparam FULL_TIME = PERIOD * 512;
    
    always #PERIOD_HALF clk = !clk;

    initial begin
        clk = 0;
        #PERIOD;
        nrst = 0;
        #PERIOD;
        nrst = 1;
        #PERIOD;

        #FULL_TIME;
        $finish;
    end
endmodule
