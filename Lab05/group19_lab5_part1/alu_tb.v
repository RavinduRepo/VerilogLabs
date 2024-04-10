`timescale 1ns / 1ps
`include "alu.v"

module alu_tb;

// Inputs
reg [7:0] data1;
reg [7:0] data2;
reg [2:0] select;

// Output
wire [7:0] result;

// Instantiate the ALU module
alu alu_instance (
    .data1(data1), 
    .data2(data2), 
    .result(result), 
    .select(select)
);

initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_instance);
    // Initialize Inputs
    data1 = 0;
    data2 = 0;
    select = 3'b000;

    // Wait 10 ns for global reset to finish
    #10;
    
    // Test forward operation
    data1 = 8'hAA; // Example data
    data2 = 8'h55; // Example data
    select = 3'b000;
    #10; // Wait for the operation to complete

    // Test addition operation
    data2 = 8'h03; // Positive data2 for addition
    select = 3'b001;
    #10; // Wait for the operation to complete

    // Test subtraction operation
    data2 = -8'h03; // Negative data2 for subtraction
    select = 3'b001;
    #10; // Wait for the operation to complete

    // Test AND operation
    select = 3'b010;
    #10; // Wait for the operation to complete

    // Test OR operation
    select = 3'b011;
    #10; // Wait for the operation to complete

    // Finish the simulation
    $finish;
end

endmodule
