`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2026 06:38:38 AM
// Design Name: 
// Module Name: pwm_tb
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


module pwm_tb;
    localparam CLK_FREQ = 100_000_000;
    localparam PWM_FREQ = 10_000_000;
    localparam VALUE_MAX = 1023;
    localparam WIDTH = $clog2(VALUE_MAX);
    localparam CLOCK_PERIOD = 1_000_000_000 / CLK_FREQ;
    localparam CLOCK_PERIOD_HALF = CLOCK_PERIOD / 2;
    localparam PWM_PERIOD = 1_000_000_000 / PWM_FREQ;

    localparam TEST_MARGIN = 1;

    reg clk;
    reg arstn;
    reg [WIDTH:0] value;
    wire out;

    pwm #(
        .CLK_FREQ(CLK_FREQ),
        .PWM_FREQ(PWM_FREQ),
        .VALUE_MAX(VALUE_MAX)
    ) pwm_0 (
        .clk(clk),
        .arstn(arstn),
        .value(value),
        .out(out)
    );

    always #CLOCK_PERIOD_HALF clk = !clk;

    task automatic check_case;
        input [WIDTH:0] value_test;
        reg [WIDTH:0] output_value;
        reg [WIDTH:0] diff;
        integer i;

        reg [WIDTH:0] value_expected;

        begin
            output_value = 0;
            value = value_test;
            value_expected = (value_test <= (VALUE_MAX + 1)) ? value_test : (VALUE_MAX + 1);

            for (i = 0; i <= VALUE_MAX; i = i + 1) begin
                #PWM_PERIOD;
                output_value = output_value + out;
            end

            diff = output_value - value_expected;
            if ((diff >= -TEST_MARGIN) || (diff <= TEST_MARGIN))
                $display("SUCCESS value: %d expected: %d", value, value_expected);
            else
                $display("FAIL    value: %d expected: %d got: %d", value, value_expected, output_value);
        end
    endtask

    initial begin
        arstn = 0;
        clk = 0;
        value = 0;
        #CLOCK_PERIOD;
        arstn = 1;
        #CLOCK_PERIOD;

        check_case(333);
        check_case(555);
        check_case(0);
        check_case(VALUE_MAX);
        check_case(VALUE_MAX + 100);

        $finish;
    end
endmodule
