`timescale 1ns/1ps

module tb;
    reg [1:0] addr4;
    wire [3:0] out4;
    decoder dec4(.addr(addr4), .out(out4));

    reg [2:0] addr8;
    wire [7:0] out8;
    decoder #(8) dec8 (.addr(addr8), .out(out8));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        #10;
        addr4 = 1;
        #1;
        $display("out4: %d", out4);
        #10;
        addr4 = 2;
        #1;
        $display("out4: %d", out4);

        #10
        addr8 = 3;
        #1;
        $display("out8: %d", out8);
        #10;
        addr8 = 6;
        #1;
        $display("out8: %d", out8);
        #10;

        $finish;
    end
endmodule