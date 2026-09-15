`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2026 07:16:45 AM
// Design Name: 
// Module Name: tb_lock_controller
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


module tb_lock_controller;
    logic clk;
    logic rst;
    logic [3:0] digit_in;
    logic unlocked_led;

    lock_controller lc(.clk(clk), .rst(rst), .digit_in(digit_in), .unlocked_led(unlocked_led));

    always #5 clk = !clk;

    initial begin
        clk = 0;
        #10

        rst = 1;
        #10

        rst = 0;
        #10

        digit_in = 6;
        #10 // Debounce
        #10
        #10
        #10
        #10
        #10
        
        #10 // state <= next_state


        $display("unlocked_led: %d", unlocked_led);
        digit_in = 3;
        #10 // Debounce
        #10
        #10
        #10
        #10
        #10
        
        #10 // state <= next_state

        $display("unlocked_led: %d", unlocked_led);
        digit_in = 8;
        #10 // Debounce
        #10
        #10
        #10
        #10
        #10
        
        #10 // state <= next_state

        $display("unlocked_led: %d", unlocked_led);

        rst = 1;
        #10

        $display("unlocked_led: %d", unlocked_led);
        rst = 0;

        digit_in = 1;
        #10 // Debounce
        #10
        #10
        #10
        #10
        #10
        
        #10 // state <= next_state

        $display("unlocked_led: %d", unlocked_led);
        digit_in = 2;
        #10 // Debounce
        #10
        #10
        #10
        #10
        #10
        
        #10 // state <= next_state

        $display("unlocked_led: %d", unlocked_led);
        digit_in = 7;
        #10 // Debounce
        #10
        #10
        #10
        #10
        #10
        
        #10 // state <= next_state

        $display("unlocked_led: %d", unlocked_led);
        #10
        #10
        
        $finish;
    end
endmodule
