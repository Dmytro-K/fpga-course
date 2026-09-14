`timescale 1ns/1ps

module tb;

    reg clk = 0;
    reg reset = 0;
    reg led1;
    reg led2;
    reg led3;
    reg led4;

    counter cnt(clk, reset, led1, led2, led3, led4);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        #10;
        reset = 1;
        #10;
        reset = 0;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        clk = !clk;
        #5
        $finish;
    end

endmodule