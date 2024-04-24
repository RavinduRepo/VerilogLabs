/*
    * CO224 - Computer Architecture
    * Lab 05 - Part 3
    * reg_file module
    * Version 1.0
*/

`include "cpu.v"

module Testbench;
    reg CLK, RESET;
    wire [31:0] PC;
    reg [31:0] INSTRUCTION;

    cpu mycpu(PC, INSTRUCTION, CLK, RESET);

    always @ (PC)
    begin
        # 2 // Latency for instruction register
        // Manually written opcodes
        case (PC)
            32'b0000_0000_0000_0000_0000_0000_0000_0000: INSTRUCTION = 32'b00000000_00000100_00000000_00000101; // loadi 4 0x05
            
            32'b0000_0000_0000_0000_0000_0000_0000_0100: INSTRUCTION = 32'b00000000_00000010_00000000_00001001; // loadi 2 0x09

            32'b0000_0000_0000_0000_0000_0000_0000_1000: INSTRUCTION = 32'b00000010_00000110_00000100_00000010; // add 6 4 2

            32'b0000_0000_0000_0000_0000_0000_0000_1100: INSTRUCTION = 32'b00000001_00000000_00000000_00000110; // mov 0 6
            
            32'b0000_0000_0000_0000_0000_0000_0001_0000: INSTRUCTION = 32'b00000000_00000001_00000000_00000001; // loadi 1 0x01
            
            32'b0000_0000_0000_0000_0000_0000_0001_0100: INSTRUCTION = 32'b00000010_00000010_00000010_00000001; // add 2 2 1
        endcase
    end

    initial begin
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, mycpu);
        
        
        RESET = 1'b0;
        CLK = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        RESET = 1;
        #6
        RESET = 0;
        // finish simulation after some time
        #100
        $finish;
    end
        
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
    
endmodule