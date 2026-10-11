`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2026 04:19:16 AM
// Design Name: 
// Module Name: task12_tb
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


module task12_tb;
    integer i;
    reg [7:0] data;
    reg clk = 0;
    reg rst = 1;
    reg btn;
    reg data_available;

    always #5 clk = ~clk;
    
    wire [8:0] data_to_module;
    assign data_to_module[7:0] = data;
    assign data_to_module[8] = data_available;
    
    design_1_wrapper dut(
        .clk(clk),
        .rst(rst),
        .gpio_btn_tri_i(btn),
        .data(data_to_module)
    );
    
    localparam IMAGE_SIZE = 320 * 200;
    
    reg [7:0] image[0:IMAGE_SIZE];

    initial begin
        $display("read start");
        $readmemh("image.mem", image);
        $display("read end");

        btn = 0;
        data_available = 0;
        #200;
        rst = 0;

        // Дати MicroBlaze час "прокинутись" і дійти до while(1) --
        // орієнтовний запас, скоригувати за спостереженням у Waveform
        #100000;

        btn = 1;
        #1000;
        btn = 0;
        #10000;

        for(i = 0; i < IMAGE_SIZE; ++i) begin
            data = image[i];
            #10;
            data_available = 1;
            #50;
            data_available = 0;
            #50;
        end
        #100000;
        $finish;
    end
endmodule
