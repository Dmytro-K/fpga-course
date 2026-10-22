`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2026 06:05:21 AM
// Design Name: 
// Module Name: fifo_tb
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


module fifo_tb;
    localparam CLOCK_PERIOD = 10;
    localparam CLOCK_PERIOD_HALF = CLOCK_PERIOD / 2;
    localparam WIDTH = 32;
    localparam ADDR_WIDTH = 2;
    reg clk;
    reg arstn;

    reg [WIDTH - 1:0] din;
    wire [WIDTH - 1:0] dout;
    reg wvalid;
    reg rready;
    wire rvalid;

    fifo #(
        .WIDTH(WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) fifo_0 (
        .clk(clk),
        .arstn(arstn),
        .din(din),
        .dout(dout),
        .wvalid(wvalid),
        .rready(rready),
        .rvalid(rvalid)
    );

    always #CLOCK_PERIOD_HALF clk = !clk;

    task automatic check_case;
        input [WIDTH - 1:0] value;
        begin
            if (rvalid)
                if (dout === value)
                    $display("SUCCESS expected: %d", value);
                else
                    $display("FAIL    expected: %d got: %d", value, dout);
            else
                $display("FAIL READ NOT VALID");
            rready = 1;
            #CLOCK_PERIOD;
            rready = 0;
            #CLOCK_PERIOD;
        end
    endtask

    task automatic write;
        input [WIDTH - 1:0] value;
        begin
            din = value;
            wvalid = 1;
            #CLOCK_PERIOD;
            wvalid = 0;
            #CLOCK_PERIOD;
        end
    endtask

    initial begin
        clk = 0;
        arstn = 0;
        din = 0;
        wvalid = 0;
        rready = 0;

        #CLOCK_PERIOD;
        arstn = 1;
        #CLOCK_PERIOD;

        write(333);
        write(222);
        write(444);

        check_case(333);
        check_case(222);
        check_case(444);

        write(22);
        write(33);
        write(44);
        write(55);
        write(66);

        check_case(33);
        check_case(44);
        check_case(55);
        check_case(66);

        if (!rvalid)
            $display("SUCCESS fifo is empty at the end");
        else
            $display("FAIL fifo NOT is empty at the end");

        $finish;
    end
endmodule
