module latch_by_mistake (input a, input b, input sel, output reg out);
    always_comb begin
        if (sel === 0)
            out = a;
        else
            out = b;
    end
endmodule