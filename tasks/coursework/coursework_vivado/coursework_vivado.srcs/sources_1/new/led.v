`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 07:17:15 AM
// Design Name: 
// Module Name: led
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


module led #(
        parameter CLK_FREQ = 125_000_000,
        parameter PWM_FREQ = 1_000_000,
        parameter VALUE_MAX = 1023,
        parameter WIDTH = $clog2(VALUE_MAX),
        parameter LED_N = 5,
        parameter BUS_DATA_WIDTH = 32,
        parameter ADDR_WIDTH = $clog2(LED_N * BUS_DATA_WIDTH / 8)
    ) (
        input s_axi_aclk,
        input s_axi_aresetn,
        input [ADDR_WIDTH - 1:0] s_axi_awaddr,
        input s_axi_awvalid,
        output s_axi_awready,
        input [BUS_DATA_WIDTH - 1:0] s_axi_wdata,
        input [3:0] s_axi_wstrb,
        input s_axi_wvalid,
        output s_axi_wready,
        output [1:0] s_axi_bresp,
        output reg s_axi_bvalid,
        input s_axi_bready,
        input [ADDR_WIDTH - 1:0] s_axi_araddr,
        input s_axi_arvalid,
        output s_axi_arready,
        output [BUS_DATA_WIDTH - 1:0] s_axi_rdata,
        output [1:0] s_axi_rresp,
        output reg s_axi_rvalid,
        input s_axi_rready,
        
        output [LED_N - 1:0] leds
    );
    
    reg [WIDTH:0] values[0:LED_N - 1];
    
    wire [ADDR_WIDTH - 3:0] led_i = s_axi_awaddr[ADDR_WIDTH - 1:2];

    genvar i;
    generate
        for (i = 0; i < LED_N; i = i + 1) begin : gen_led
             pwm #(
                .CLK_FREQ(CLK_FREQ),
                .PWM_FREQ(PWM_FREQ),
                .VALUE_MAX(VALUE_MAX)
                ) pwm_inst (
                .clk(s_axi_aclk),
                .arstn(s_axi_aresetn),
                .value(values[i]),
                .out(leds[i])
            );
        end
    endgenerate

    wire write_accept = s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid;
    assign s_axi_awready = write_accept;
    assign s_axi_wready  = write_accept;
    
    assign s_axi_arready = !s_axi_rvalid;
    assign s_axi_rdata = 0;

    assign s_axi_bresp = 0;
    assign s_axi_rresp = 0;
    
    integer k;
    
    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            for (k = 0; k < LED_N; k = k + 1)
                values[k] <= 0;
            s_axi_bvalid <= 0;
            s_axi_rvalid <= 0;
        end
        else begin
            if (write_accept) begin
                if (led_i < LED_N)
                    values[led_i] <= s_axi_wdata[WIDTH:0];
                s_axi_bvalid <= 1;
            end
            if (s_axi_bvalid && s_axi_bready)
                s_axi_bvalid <= 0;
            if (s_axi_arvalid && s_axi_arready)
                s_axi_rvalid <= 1;
            if (s_axi_rvalid && s_axi_rready)
                s_axi_rvalid <= 0;
        end
    end
endmodule
