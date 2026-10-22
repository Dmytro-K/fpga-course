`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2026 06:49:13 PM
// Design Name: 
// Module Name: led_tb
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


module led_tb;
    localparam CLK_FREQ = 100_000_000;
    localparam PWM_FREQ = 10_000_000;
    localparam VALUE_MAX = 1023;
    localparam WIDTH = $clog2(VALUE_MAX);
    localparam CLOCK_PERIOD = 1_000_000_000 / CLK_FREQ;
    localparam CLOCK_PERIOD_HALF = CLOCK_PERIOD / 2;
    localparam PWM_PERIOD = 1_000_000_000 / PWM_FREQ;
    localparam LED_N = 2;
    localparam BUS_DATA_WIDTH = 32;
    localparam ADDR_WIDTH = $clog2(LED_N * BUS_DATA_WIDTH / 8);

    localparam TEST_MARGIN = 1;

    reg clk;
    reg arstn;
    reg [WIDTH:0] value;

    reg [ADDR_WIDTH - 1:0] s_axi_awaddr;
    reg s_axi_awvalid;
    wire s_axi_awready;
    wire [BUS_DATA_WIDTH - 1:0] s_axi_wdata;
    reg [3:0] s_axi_wstrb;
    reg s_axi_wvalid;
    wire s_axi_wready;
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    reg s_axi_bready;
    reg [ADDR_WIDTH - 1:0] s_axi_araddr;
    reg s_axi_arvalid;
    wire s_axi_arready;
    wire [BUS_DATA_WIDTH - 1:0] s_axi_rdata;
    wire [1:0] s_axi_rresp;
    wire s_axi_rvalid;
    reg s_axi_rready;

    wire [LED_N - 1:0] leds;

    led #(
        .CLK_FREQ(CLK_FREQ),
        .PWM_FREQ(PWM_FREQ),
        .VALUE_MAX(VALUE_MAX),
        .LED_N(LED_N)
    ) led_0 (
        .s_axi_aclk(clk),
        .s_axi_aresetn(arstn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .leds(leds)
    );

    always #CLOCK_PERIOD_HALF clk = !clk;

    assign s_axi_wdata[WIDTH:0] = value;

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

            s_axi_awvalid = 1;
            s_axi_wvalid = 1;

            while (!s_axi_bvalid)
                #CLOCK_PERIOD;

            s_axi_awvalid = 0;
            s_axi_wvalid = 0;
            s_axi_bready = 1;
            #CLOCK_PERIOD;
            s_axi_bready = 0;

            for (i = 0; i <= VALUE_MAX; i = i + 1) begin
                #PWM_PERIOD;
                output_value = output_value + leds[0];
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
        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wstrb = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_araddr = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;

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
