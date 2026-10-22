`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 09:05:42 AM
// Design Name: 
// Module Name: i2s_input_tb
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


module i2s_input_tb;
    localparam CLK_FREQ = 100_000_000;
    localparam CLOCK_PERIOD = 1_000_000_000 / CLK_FREQ;
    localparam CLOCK_PERIOD_HALF = CLOCK_PERIOD / 2;
    localparam BUS_DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 4;
    localparam MIC_FREQ = 16000;
    localparam MIC_DATA_WIDTH = 24;
    localparam MIC_CHANNEL = 0;

    localparam ADDR_STATUS = 0;
    localparam ADDR_DATA = 1;

    localparam DATA_LEN = 16000;
    localparam TIME_LIMIT = 64'd1 * CLK_FREQ * DATA_LEN / MIC_FREQ;

    reg [MIC_DATA_WIDTH - 1:0] data[0:DATA_LEN - 1];
    reg [BUS_DATA_WIDTH - 1:0] data_out[0:DATA_LEN - 1];

    reg clk;
    reg arstn;

    reg [ADDR_WIDTH - 1:0] s_axi_awaddr;
    reg s_axi_awvalid;
    wire s_axi_awready;
    reg [BUS_DATA_WIDTH - 1:0] s_axi_wdata;
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

    wire mic_sck;
    wire mic_ws;
    reg mic_sd;

    i2s_input #(
        .CLK_FREQ(CLK_FREQ),
        .MIC_FREQ(MIC_FREQ),
        .MIC_DATA_WIDTH(MIC_DATA_WIDTH)
    ) i2s_0 (
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
        .mic_sck(mic_sck),
        .mic_ws(mic_ws),
        .mic_sd(mic_sd)
    );

    always #CLOCK_PERIOD_HALF clk = !clk;

    task automatic read_axi;
        output [BUS_DATA_WIDTH - 1:0] dout;
        output valid;
        reg data_exist;
        begin
            data_exist = 0;
            s_axi_rready = 0;
            s_axi_araddr = ADDR_STATUS << 2;
            s_axi_arvalid = 1;

//            $display(1);
            while (!s_axi_arready)
                #CLOCK_PERIOD;
            #CLOCK_PERIOD;
//            $display(2);

            s_axi_arvalid = 0;

//            $display(3);
            while (!s_axi_rvalid)
                #CLOCK_PERIOD;
//            $display(4);

            data_exist = s_axi_rdata;
            s_axi_rready = 1;

            #CLOCK_PERIOD;
            s_axi_rready = 0;

            if (data_exist) begin
                s_axi_araddr = ADDR_DATA << 2;
                s_axi_arvalid = 1;

//            $display(5);
                while (!s_axi_arready)
                    #CLOCK_PERIOD;
            #CLOCK_PERIOD;
//            $display(6);

                s_axi_arvalid = 0;

//            $display(7);
                while (!s_axi_rvalid)
                    #CLOCK_PERIOD;
//            $display(8);

                dout = s_axi_rdata;

                s_axi_rready = 1;

                #CLOCK_PERIOD;
                s_axi_rready = 0;

                valid = 1;
            end
        end
    endtask

    integer data_i, data_out_i;
    reg mic_sck_prev;
    reg [4:0] mic_bit;
    reg valid;
    integer elapsed;
    reg test_ok;

    initial begin
        $readmemh("signal.mem", data);
        arstn = 0;
        clk = 0;
        s_axi_awaddr = 0;
        s_axi_awvalid = 0;
        s_axi_wdata = 0;
        s_axi_wstrb = 0;
        s_axi_wvalid = 0;
        s_axi_bready = 0;
        s_axi_araddr = 0;
        s_axi_arvalid = 0;
        s_axi_rready = 0;
        mic_sck_prev = 0;
        mic_bit = 0;
        data_i = 0;
        data_out_i = 0;
        elapsed = 0;

        #CLOCK_PERIOD;
        arstn = 1;
        #CLOCK_PERIOD;

        while ((data_out_i < DATA_LEN) && (elapsed < TIME_LIMIT)) begin
            elapsed = elapsed + 1;
//            $display("elapsed: %d", elapsed);

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

            valid = 0;
//            $display(1);
            read_axi(data_out[data_out_i], valid);
//            $display(2);

            if (valid)
                data_out_i = data_out_i + 1;

            #CLOCK_PERIOD;
        end

        test_ok = 1;
        begin : loop
        for (data_i = 0; data_i < DATA_LEN; data_i = data_i + 1)
            if (data[data_i][MIC_DATA_WIDTH - 1:0] != data_out[data_i][MIC_DATA_WIDTH - 1:0]) begin
                $display("FAIL - data mismatch at %d!", data_i);
                test_ok = 0;
                disable loop;
            end
        end

        if (test_ok)
            $display("SUCCESS!");

        $finish;
    end
endmodule
