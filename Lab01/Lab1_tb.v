`timescale 1ns/1ns
`include "Lab1.v" 

module Lab1_tb;

reg [7:0] A;
reg [7:0] B;
reg S;
wire [7:0] Z;


logicSelector uut(A, B, S, Z);

    initial begin
        A = 0; B = 0;

        $dumpfile("Lab1.vcd");
        $dumpvars(0, Lab1_tb);
        $monitor($time, "C = %b",Z);

        #100
        A = 8'd54; B = 8'd0; S = 1'b0;
        #5 A = 8'd5; B = 8'd2; S = 1'b0;
        #5 A = 8'd7; B = 8'd0; S = 1'b0;
        #5 A = 8'd10; B = 8'd20; S = 1'b1;
        #5A = 8'd2; B = 8'd14; S = 1'b0;



        $finish;
    end
endmodule