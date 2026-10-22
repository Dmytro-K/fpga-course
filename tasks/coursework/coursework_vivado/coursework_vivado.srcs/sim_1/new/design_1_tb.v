`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2026 05:24:21 AM
// Design Name: 
// Module Name: design_1_tb
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


module design_1_tb;
    localparam CLK_FREQ = 125_000_000;
    localparam CLOCK_PERIOD = 1_000_000_000 / CLK_FREQ;
    localparam CLOCK_PERIOD_HALF = CLOCK_PERIOD / 2;

    localparam PWM_FREQ = 1_000_000;
    localparam VALUE_MAX = 1023;
    localparam WIDTH = $clog2(VALUE_MAX);
    localparam LED_N = 5;
    localparam PWM_PERIOD = 1_000_000_000 / PWM_FREQ;

    localparam MIC_FREQ = 16000;
    localparam MIC_DATA_WIDTH = 24;
    localparam MIC_CHANNEL = 0;

    localparam DATA_LEN = 1024;
    localparam TIME_LIMIT = 64'd1 * CLK_FREQ * DATA_LEN / MIC_FREQ * 2;
    

    localparam FFT_SIZE = 128;
    localparam FRAMES_COUNT = DATA_LEN / FFT_SIZE;
    localparam LED_FILE_SIZE = FRAMES_COUNT * LED_N;

    localparam I2S_WIDTH = 32;
    localparam FFT_FRAME_TIME = (CLK_FREQ / (MIC_FREQ * I2S_WIDTH * 2) / 2) * 2 * I2S_WIDTH * 2 * FFT_SIZE;
//    localparam FFT_FRAME_TIME = 64'd1 * CLK_FREQ * FFT_SIZE / MIC_FREQ;

    localparam TEST_MARGIN = 16;

    reg [MIC_DATA_WIDTH - 1:0] data[0:DATA_LEN - 1];
//    reg [BUS_DATA_WIDTH - 1:0] data_out[0:DATA_LEN - 1];
    reg [31:0] data_led[0:LED_FILE_SIZE - 1];

    reg rst;
    reg clk;

    wire [LED_N - 1:0] leds;
    wire mic_sck;
    reg mic_sd;
    wire mic_ws;

    design_1_wrapper dut(
        .led(leds),
        .mic_sck(mic_sck),
        .mic_sd(mic_sd),
        .mic_ws(mic_ws),
        .reset(rst),
        .sys_clock(clk)
    );

    always #CLOCK_PERIOD_HALF clk = !clk;

    integer data_i, data_out_i;
    reg mic_sck_prev;
    reg [4:0] mic_bit;
//    reg valid;
    integer elapsed;
    integer timestamp_next_check;
    integer current_frame;
//    reg test_ok;
    integer i, j;
    integer errors;
    integer diff;

    reg [WIDTH - 1:0] output_value[0:LED_N - 1];
    reg [WIDTH - 1:0] output_value_saved[0:LED_N - 1];

    initial begin
        elapsed = 0;
        while (elapsed < TIME_LIMIT) begin
            elapsed = elapsed + 1;
            #CLOCK_PERIOD;
        end
        $finish;
    end

    initial begin
        $readmemh("signal.mem", data);
        rst = 1;
        clk = 0;
        mic_sck_prev = 0;
        mic_bit = 0;
        data_i = 0;
//        data_out_i = 0;

        #CLOCK_PERIOD;
        rst = 0;
        #CLOCK_PERIOD;

        while (1) begin
            if (data_i < DATA_LEN)
                if (mic_sck_prev && !mic_sck && (mic_ws == MIC_CHANNEL)) begin
                    if (mic_bit < MIC_DATA_WIDTH)
                        mic_sd = data[data_i][MIC_DATA_WIDTH - mic_bit - 1];
                    else
                        mic_sd = 0;

                    mic_bit = mic_bit + 1;

                    if (mic_bit == 0)
                        data_i = data_i + 1;
                end

            if (mic_sck_prev != mic_sck)
                mic_sck_prev = mic_sck;

            #CLOCK_PERIOD;
        end
    end

    initial begin
        $readmemh("leds.mem", data_led);

        timestamp_next_check = 0;
        current_frame = 0;
        errors = 0;

        for (j = 0; j < LED_N; j = j + 1) begin
            output_value_saved[j] = 0;
            output_value[j] = 0;
        end

        while (elapsed < FFT_FRAME_TIME / 2) begin
            #CLOCK_PERIOD;
        end

        timestamp_next_check = elapsed + FFT_FRAME_TIME;

        while (current_frame < FRAMES_COUNT) begin
            for (j = 0; j < LED_N; j = j + 1)
                output_value[j] = 0;

            for (i = 0; i < VALUE_MAX; i = i + 1) begin
                #PWM_PERIOD;
                for (j = 0; j < LED_N; j = j + 1)
                    output_value[j] = output_value[j] + leds[j];
            end

            for (j = 0; j < LED_N; j = j + 1)
                output_value_saved[j] = output_value[j];

            if (elapsed - timestamp_next_check >= 0) begin
                timestamp_next_check = timestamp_next_check + FFT_FRAME_TIME;

                for (j = 0; j < LED_N; j = j + 1) begin
                    diff = output_value_saved[j] - data_led[(current_frame * LED_N) + j];
                    
                    if ((diff <= TEST_MARGIN) && (diff >= (-TEST_MARGIN))) begin
                        $display("Check at timestamp: %d for led: %d SUCCESS", elapsed, j);
                    end
                    else begin
                        $display("Check at timestamp: %d for led: %d FAIL diff: %d", elapsed, j, diff);
                        errors = errors + 1;
                    end
                end

                current_frame = current_frame + 1;
            end
         end

         if (errors)
            $display("Test FAIL with %d errors", errors);
         else
            $display("Test SUCCESS");

         $finish;
    end
endmodule
