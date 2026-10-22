`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 04:46:09 AM
// Design Name: 
// Module Name: top
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

module top #(
    parameter ADDR_WIDTH = 4,
    parameter BUS_DATA_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter CLK_FREQ = 100_000_000,
    parameter OUT_FREQ = 10
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

    output [4:0] led
    );

    assign s_axi_bresp = 0;
    assign s_axi_rresp = 0;

    reg [DATA_WIDTH - 1:0] counter;

    reg [31:0] clk_cnt;

    localparam CLK_CNT_LIMIT = (CLK_FREQ / OUT_FREQ) - 1;

    localparam ADDR_STATUS = 0;
    localparam ADDR_DATA = 1;

    assign s_axi_arready = !s_axi_rvalid;
    assign s_axi_awready = s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid;
    assign s_axi_wready = s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid;

    reg [DATA_WIDTH - 1:0] fifo_din;
    wire [DATA_WIDTH - 1:0] fifo_dout;
    reg fifo_wvalid;
    reg fifo_rready;
    wire fifo_rvalid;

    fifo  #(.WIDTH(DATA_WIDTH), .ADDR_WIDTH(4)) fifo_0 (
        .clk(s_axi_aclk),
        .arstn(s_axi_aresetn),
        .din(fifo_din),
        .dout(fifo_dout),
        .wvalid(fifo_wvalid),
        .rready(fifo_rready),
        .rvalid(fifo_rvalid)
    );
    
    assign led = counter;

    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            counter <= 0;
            clk_cnt <= 0;
            s_axi_rdata <= 0;
            s_axi_rvalid <= 0;
            s_axi_bvalid <= 0;
            fifo_wvalid <= 0;
            fifo_rready <= 0;
            fifo_din <= 0;
        end
        else begin
            fifo_rready <= 0;

            if (clk_cnt == CLK_CNT_LIMIT) begin
                fifo_din <= counter;
                counter <= counter + 1;
                clk_cnt <= 0;
                fifo_wvalid <= 1;
            end
            else begin
                clk_cnt <= clk_cnt + 1;
                fifo_wvalid <= 0;
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
