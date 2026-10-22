`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 05:47:42 AM
// Design Name: 
// Module Name: i2s
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


module i2s_input #(
        parameter ADDR_WIDTH = 4,
        parameter BUS_DATA_WIDTH = 32,
        parameter CLK_FREQ = 125_000_000,
        parameter MIC_FREQ = 16000,
        parameter MIC_DATA_WIDTH = 24,
        parameter I2S_WIDTH = 32,
        parameter FIFO_DATA_WIDTH = I2S_WIDTH
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
        output reg [BUS_DATA_WIDTH - 1:0] s_axi_rdata,
        output [1:0] s_axi_rresp,
        output reg s_axi_rvalid,
        input s_axi_rready,
    
        output reg mic_sck,
        output reg mic_ws,
        input mic_sd
    );

    wire [FIFO_DATA_WIDTH - 1:0] fifo_din;
    wire [FIFO_DATA_WIDTH - 1:0] fifo_dout;
    reg fifo_wvalid;
    reg fifo_rready;
    wire fifo_rvalid;

    fifo  #(.WIDTH(FIFO_DATA_WIDTH), .ADDR_WIDTH(4)) fifo_0 (
        .clk(s_axi_aclk),
        .arstn(s_axi_aresetn),
        .din(fifo_din),
        .dout(fifo_dout),
        .wvalid(fifo_wvalid),
        .rready(fifo_rready),
        .rvalid(fifo_rvalid)
    );

    localparam I2S_FREQ = MIC_FREQ * I2S_WIDTH * 2;
    localparam CLK_I2S_RATIO_HALF = CLK_FREQ / I2S_FREQ / 2;

    reg [31:0] clk_counter;
    reg [4:0] mic_bit;
    reg [I2S_WIDTH - 1:0] data;

    assign fifo_din = {{8{data[30]}}, data[30:7]};

    localparam ADDR_STATUS = 0;
    localparam ADDR_DATA = 1;

    assign s_axi_arready = !s_axi_rvalid;
    assign s_axi_awready = s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid;
    assign s_axi_wready = s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid;

    assign s_axi_bresp = 0;
    assign s_axi_rresp = 0;

    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            s_axi_rdata <= 0;
            s_axi_rvalid <= 0;
            s_axi_bvalid <= 0;
            fifo_wvalid <= 0;
            fifo_rready <= 0;

            mic_sck <= 0;
            mic_ws <= 0;

            clk_counter <= 0;
            mic_bit <= 0;
            data <= 0;
        end
        else begin
            fifo_rready <= 0;
            fifo_wvalid <= 0;

            if (clk_counter == CLK_I2S_RATIO_HALF - 1) begin
                mic_sck <= !mic_sck;
                clk_counter <= 0;

                if (mic_sck) begin // negedge mic_sck
                    if (mic_bit == I2S_WIDTH - 1) begin
                        mic_bit <= 0;
                        mic_ws <= !mic_ws;

                        if (!mic_ws)
                            fifo_wvalid <= 1;
                    end
                    else begin
                        mic_bit <= mic_bit + 1;
                    end
                end
                else begin // posedge mic_sck
                    data <= (data << 1) | mic_sd;
                end
            end
            else begin
                clk_counter <= clk_counter + 1;
            end

            if (s_axi_arvalid && s_axi_arready) begin
                case (s_axi_araddr[ADDR_WIDTH - 1:2])
                    ADDR_STATUS: begin
                        s_axi_rdata <= fifo_rvalid;
                        s_axi_rvalid <= 1;
                    end
                    ADDR_DATA: begin
                        s_axi_rdata <= fifo_dout;
                        s_axi_rvalid <= 1;
                        fifo_rready <= 1;
                    end
                    default: begin
                        s_axi_rdata <= 0;
                        s_axi_rvalid <= 1;
                        end
                endcase
            end
            else if (s_axi_rvalid && s_axi_rready)
                s_axi_rvalid <= 0;

            if (s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid)
                s_axi_bvalid <= 1;
            else if (s_axi_bvalid && s_axi_bready)
                s_axi_bvalid <= 0;
        end
    end
endmodule
