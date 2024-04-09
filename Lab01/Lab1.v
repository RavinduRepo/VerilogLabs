module andUnit(A,B,C);
    input [7:0] A;
    input [7:0] B;
    output [7:0] C;

assign C = A & B;

endmodule

module orUnit(A,B,D);
    input [7:0] A;
    input [7:0] B;
    output [7:0] D;

assign D = A | B;

endmodule

module muxUnit(C,D,S,Z);
    input [7:0] C;
    input [7:0] D;
    input S;
    output [7:0] Z;

assign Z = S ? D : C;

endmodule

module logicSelector(A,B,S,Z);
    input [7:0] A;
    input [7:0] B;
    input S;
    output [7:0] Z;

wire [7:0] C;
wire [7:0] D;

andUnit and_gate(A, B, C);
orUnit or_gate(A, B, D);
muxUnit selector(C, D, S, Z);

endmodule