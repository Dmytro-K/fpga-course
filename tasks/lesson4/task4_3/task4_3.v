module counter (
    input clk,
    input reset,
    output reg a,
    output reg b,
    output reg c,
    output reg d
);
    reg [3:0] cnt;

    assign a = cnt[0];
    assign b = cnt[1];
    assign c = cnt[2];
    assign d = cnt[3];

    always @(posedge clk or posedge reset) begin
        if (reset)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
endmodule