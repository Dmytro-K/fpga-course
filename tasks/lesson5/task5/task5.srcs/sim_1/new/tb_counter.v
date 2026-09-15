`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2026 09:14:25 AM
// Design Name: 
// Module Name: tb_counter
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

module tb_counter;
    reg clk;
    reg rst;
    reg load;
    reg [3:0] data_in;
    reg en;
    reg up_down;
    wire [3:0] count;

    always #5 clk = !clk;

    counter cnt(.clk(clk), .rst(rst), .load(load), .data_in(data_in), .en(en),
        .up_down(up_down), .count(count));

    task automatic check_count;
        input [3:0] expected;
        input [8*16-1:0] name;
        
        begin
            $display("count: %d", count);
            if (count === expected)
                $display("Test '%s' PASS", name);
            else
                $display("Test '%s' FAIL", name);
        end
    endtask

    initial begin
        #10
        $display("count: %d", count);
        rst = 1;
        clk = 0;
        load = 0;
        data_in = 0;
        #5
        #5
        $display("count: %d", count);
        rst = 0;
        en = 1;
        up_down = 1;

        data_in = 4'd10;
        load = 1;
        #5
        #5
        check_count(10, "LOAD");
        
        load = 0;
        en = 1;
        up_down = 1;

        #5
        #5
        
        #5
        #5
        
        #5
        #5

        check_count(13, "COUNT UP");

        #5
        #5

        #5
        #5

        #5
        #5

        check_count(0, "UP OVERFLOW");

        en = 0;
        #5
        #5

        #5
        #5

        check_count(0, "en=0");

        en = 1;
        up_down = 0;

        #5
        #5

        check_count(15, "DOWN OVERFLOW");

        load = 1;
        data_in = 4'd5;
        en = 1;
        up_down = 1;
        #5

        check_count(5, "LOAD PRIO");

        load = 0;
        en = 1;
        up_down = 0;

        #5
        #5

        #5
        #5

        #5
        #5

        check_count(2, "COUNT DOWN");

        #5
        $finish;
    end
endmodule
