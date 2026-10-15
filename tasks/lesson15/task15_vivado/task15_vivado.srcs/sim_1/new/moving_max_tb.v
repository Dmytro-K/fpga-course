`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2026 06:35:21 AM
// Design Name: 
// Module Name: moving_max_tb
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


module moving_max_tb;
    reg clk;
    reg rst;

    reg start;
    wire done, ready, idle;

    reg [31:0] data[0:63];
    reg [31:0] out[0:63];

    reg [31:0] in_data_q0;
    reg [31:0] in_data_q1;
    wire [31:0] out_data_d0;
    wire [31:0] out_data_d1;

    wire in_data_ce0;
    wire in_data_ce1;
    wire out_data_ce0;
    wire out_data_ce1;
    wire out_data_we0;
    wire out_data_we1;

    wire [5:0] in_data_address0;
    wire [5:0] in_data_address1;
    wire [5:0] out_data_address0;
    wire [5:0] out_data_address1;

    moving_max_0 dut(
        .ap_clk(clk),
        .ap_rst(rst),
        .ap_start(start),
        .ap_done(done),
        .ap_ready(ready),
        .ap_idle(idle),
        .in_data_q0(in_data_q0),
        .in_data_q1(in_data_q1),
        .out_data_d0(out_data_d0),
        .out_data_d1(out_data_d1),
        .in_data_ce0(in_data_ce0),
        .in_data_ce1(in_data_ce1),
        .out_data_ce0(out_data_ce0),
        .out_data_ce1(out_data_ce1),
        .out_data_we0(out_data_we0),
        .out_data_we1(out_data_we1),
        .in_data_address0(in_data_address0),
        .in_data_address1(in_data_address1),
        .out_data_address0(out_data_address0),
        .out_data_address1(out_data_address1)
    );

    always @(posedge clk) begin
        if (in_data_ce0) in_data_q0 <= data[in_data_address0];
        if (in_data_ce1) in_data_q1 <= data[in_data_address1];
        if (out_data_ce0 && out_data_we0) out[out_data_address0] <= out_data_d0;
        if (out_data_ce1 && out_data_we1) out[out_data_address1] <= out_data_d1;
    end

    always #5 clk = !clk;

    integer i;

    initial begin
        $readmemh("numbers.mem", data);
        clk = 0;
        rst = 1;
        start = 0;
        #10;
        rst = 0;
        start = 1;

        while (!ready)
            #10;

        start = 0;

        while (!done)
            #10;

        for (i = 0; i < 64; i = i + 1) begin
            $display("out[%d]: %02x", i, out[i]);
        end
    end
endmodule
