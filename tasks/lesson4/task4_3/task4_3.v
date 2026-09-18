module counter (
    input clk,
    input reset,
    output a,
    output b,
    output c,
    output d
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
