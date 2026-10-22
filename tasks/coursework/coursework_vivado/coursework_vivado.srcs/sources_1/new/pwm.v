`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 06:44:44 AM
// Design Name: 
// Module Name: pwm
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


module pwm #(
        parameter CLK_FREQ = 100_000_000,
        parameter PWM_FREQ = 1_000_000,
        parameter VALUE_MAX = 1023,
        parameter WIDTH = $clog2(VALUE_MAX)
    ) (
        input clk,
        input arstn,
    
        input [WIDTH:0] value,
        output reg out
    );

    localparam PULSES_PER_PERIOD = VALUE_MAX; // 64'd1 * PWM_FREQ * VALUE_MAX / 1_000_000;
    localparam CLK_PWM_RATIO = CLK_FREQ / PWM_FREQ;

    reg [WIDTH - 1:0] counter;
    reg [$clog2(CLK_PWM_RATIO):0] counter_clk;

    always @(posedge clk or negedge arstn) begin
        if (!arstn) begin
            counter <= 0;
            out <= 0;
            counter_clk <= 0;
        end
        else begin
            out <= (counter < value);

            if (counter_clk == CLK_PWM_RATIO - 1) begin
                counter <= (counter >= (PULSES_PER_PERIOD - 1)) ? 0 : counter + 1;
                counter_clk <= 0;
            end
            else
                counter_clk <= counter_clk + 1;
        end
    end
endmodule
