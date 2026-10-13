`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2026 04:30:33 AM
// Design Name: 
// Module Name: task14
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


module task14(
    input clk,
    input nrst,
    output [7:0] pmod
    );

    reg [7:0] led_state;
    reg [31:0] counter;

    localparam CLK_FREQ = 100000000;
    localparam LED_FREQ = 10;
    localparam DIV = CLK_FREQ / LED_FREQ;

    assign pmod = ~led_state;

    always @(posedge clk) begin
        if (!nrst) begin
            led_state <= 0;
            counter <= 0;
        end
        else begin
            if (counter >= DIV) begin
                counter <= 0;
                led_state <= led_state + 1;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
