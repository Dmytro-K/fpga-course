`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 05:58:45 AM
// Design Name: 
// Module Name: task12
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


module task12(
    input wire clk,
    input wire rst,
    input wire [8:0] data,
    
    input wire start,

    output wire [31:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast
    );

    reg [2:0] buffer_i;
    reg [31:0] buffer;
    
    reg [15:0] pixel_n;

    wire [7:0] fifo_data;
    reg fifo_ren;
    wire fifo_wen = data[8];
    wire fifo_data_exist;
    wire fifo_ready;
    reg fifo_already_read;
    
    reg fifo_rst;

    fifo fifo1(
        .clk(clk),
        .rst(fifo_rst),
        .data_in(data[7:0]),
        .data_out(fifo_data),
        .wen(fifo_wen),
        .ren(fifo_ren),
        .data_exist(fifo_data_exist),
        .ready(fifo_ready),
        .already_read(fifo_already_read)
    );

    localparam STATE_INIT = 0;
    localparam STATE_RESET_FIFO = 1;
    localparam STATE_FIFO_READ_START = 2;
    localparam STATE_FIFO_READ = 3;
    localparam STATE_FIFO_READ_END = 4;
    localparam STATE_FIFO_READ_END_2 = 5;
    localparam STATE_SEND_TO_AXI = 6; 
    reg [3:0] state;
    
    localparam IMAGE_SIZE = 320 * 200;

    assign m_axis_tdata = buffer;

    reg axis_tvalid_reg;
    reg axis_tlast_reg;

    assign m_axis_tvalid = axis_tvalid_reg;
    assign m_axis_tlast = axis_tlast_reg;

    always @(posedge clk) begin
        if (rst) begin
            // TODO: Handle RST
            buffer <= 0;
            buffer_i <= 0;
            pixel_n <= 0;
            axis_tvalid_reg <= 0;
            state <= STATE_INIT;
            fifo_rst <= 1;
            fifo_ren <= 0;
            fifo_already_read <= 0;
            axis_tlast_reg <= 0;
        end
        else begin
            case (state)
                STATE_INIT: begin
                    if (start) begin
                        state <= STATE_RESET_FIFO;
                        fifo_rst <= 1;
                    end
                end

                STATE_RESET_FIFO: begin
                    if (!start) begin
                        state <= STATE_FIFO_READ_START;
                        fifo_rst <= 0;
                    end
                end

                STATE_FIFO_READ_START: begin
                    if (fifo_data_exist) begin
                        state <= STATE_FIFO_READ;
                        fifo_ren <= 1;
                    end
                end

                STATE_FIFO_READ: begin
                    if (fifo_ready) begin
                        state <= STATE_FIFO_READ_END;
                        fifo_ren <= 0;
//                        buffer[7:0] <= fifo_data; 
                        buffer[8*buffer_i +: 8] <= fifo_data;
                        buffer_i <= buffer_i + 1;
                        pixel_n <= pixel_n + 1;
                    end
                end

                STATE_FIFO_READ_END: begin
                    fifo_already_read <= fifo_ready;
                    if (!fifo_ready) begin
                            state <= STATE_FIFO_READ_END_2;
                    end
                end

                STATE_FIFO_READ_END_2: begin
                    if (buffer_i == 4) begin
                        axis_tvalid_reg <= 1;
                        state <= STATE_SEND_TO_AXI;
                        buffer_i <= 0;

                        if (pixel_n == IMAGE_SIZE) begin
                            axis_tlast_reg <= 1;
                        end
                    end
                    else begin
                        state <= STATE_FIFO_READ_START;
                    end
                end

                STATE_SEND_TO_AXI: begin
                    if (m_axis_tready) begin
                        axis_tvalid_reg <= 0;
                        axis_tlast_reg <= 0;
                        buffer <= 0;
                        if (pixel_n == IMAGE_SIZE) begin
                            state <= STATE_INIT;
                            pixel_n <= 0;
                        end
                        else begin
                            state <= STATE_FIFO_READ_START;
                        end
                    end
                end
            endcase
        end
    end
endmodule
