`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2026 08:43:02 PM
// Design Name: 
// Module Name: lock_controller
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


module lock_controller(
     input  logic clk,
     input  logic rst,
     input  logic [3:0] digit_in,
     output logic unlocked_led
    );
    
    typedef enum logic [1:0] {
        LOCKED,
        WAIT_D2,
        WAIT_D3,
        UNLOCKED
    } state_t;
    
    localparam DIGIT1 = 6;
    localparam DIGIT2 = 3;
    localparam DIGIT3 = 8;
    localparam DEBOUNCE_LIM = 5;
    
    state_t state;
    state_t next_state;
    
    logic [2:0] debounce_counter;

    always_ff @(posedge clk or posedge rst)
        if (rst) begin
            state <= LOCKED;
            debounce_counter <= 0;
        end
        else
            state <= next_state;

    always @(posedge clk) begin
//        next_state <= state;
//        $display("state: %d digit_in: %d next_state: %d debounce_counter: %d", state, digit_in, next_state, debounce_counter);
        case (state)
            LOCKED:
                if (digit_in === DIGIT1)
                    if (debounce_counter < DEBOUNCE_LIM)
                        debounce_counter <= debounce_counter + 1;
                    else begin
                        next_state <= WAIT_D2;
                        debounce_counter <= 0;
                    end
                else
                    next_state <= LOCKED;
            WAIT_D2:
                if (digit_in === DIGIT2)
                    if (debounce_counter < DEBOUNCE_LIM)
                        debounce_counter <= debounce_counter + 1;
                    else begin
                        next_state <= WAIT_D3;
                        debounce_counter <= 0;
                    end
                else if (digit_in !== DIGIT1)
                    next_state <= LOCKED;
            WAIT_D3:
                if (digit_in === DIGIT3)
                    if (debounce_counter < DEBOUNCE_LIM)
                        debounce_counter <= debounce_counter + 1;
                    else begin
                        next_state <= UNLOCKED;
                        debounce_counter <= 0;
                    end
                else if (digit_in !== DIGIT2)
                    next_state <= LOCKED;
            UNLOCKED:
                next_state <= UNLOCKED;
            default:
                next_state <= LOCKED;
        endcase
    end
    
    always_comb
        unlocked_led <= state === UNLOCKED;
endmodule
