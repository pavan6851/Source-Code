`timescale 1ns / 1ps
module conv_top_tb;

    reg         clk;
    reg         reset;
    wire        done;
    wire [7:0]  out0, out1, out2;
    wire [7:0]  out3, out4, out5;
    wire [7:0]  out6, out7, out8;

    conv_top uut (
        .clk   (clk),
        .reset (reset),
        .done  (done),
        .out0  (out0), .out1  (out1), .out2  (out2),
        .out3  (out3), .out4  (out4), .out5  (out5),
        .out6  (out6), .out7  (out7), .out8  (out8)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #20 reset = 0;

        // wait fixed time - long enough for all 9 positions
        // 9 positions × 15 states × 10ns = 1350ns + margin
        #3000;

        $display("done signal = %0b", done);
        $display("------ Convolution Output ------");
        $display("out[0][0] = %0d (expected 35)",  out0);
        $display("out[0][1] = %0d (expected 40)",  out1);
        $display("out[0][2] = %0d (expected 45)",  out2);
        $display("out[1][0] = %0d (expected 60)",  out3);
        $display("out[1][1] = %0d (expected 65)",  out4);
        $display("out[1][2] = %0d (expected 70)",  out5);
        $display("out[2][0] = %0d (expected 85)",  out6);
        $display("out[2][1] = %0d (expected 90)",  out7);
        $display("out[2][2] = %0d (expected 95)",  out8);
        $display("--------------------------------");

        if (out0==35  && out1==40  && out2==45  &&
            out3==60  && out4==65  && out5==70  &&
            out6==85  && out7==90  && out8==95)
            $display("ALL TESTS PASSED ✓");
        else
            $display("SOME TESTS FAILED ✗ - check waveform");

        $finish;
    end

endmodule
