
`include "cpu.v"

`define REG_ADDRESS_SIZE 3
`define REG_SIZE 8
`define OPCODE_SIZE 8
`define SH_AMT_SIZE 5
`define FUNC_SIZE 6
`define IMMIDIATE_SIZE 8
`define ADDRESS_SIZE 26

`define OPCODE_END 24
`define REGISTER_1_END 8
`define REGISTER_2_END 0
`define REGISTER_DEST_END 16

`define SH_AMT_END 6
`define FUNC_END 0
`define IMMIDIATE_END 0
`define ADDRESS_END 0
`define ALU_OP_SIZE 3

module instruction_decoder_tb;
reg [31:0] INSTRUCTION;
wire [`OPCODE_SIZE-1:0] OPCODE;
wire [`REG_ADDRESS_SIZE-1:0] REGISTER_1,REGISTER_2,REGISTER_DEST;
wire [`SH_AMT_SIZE-1:0] SH_AMT;
wire [`FUNC_SIZE-1:0] FUNC;
wire [`IMMIDIATE_SIZE-1:0] IMMIDIATE;
wire [`ADDRESS_SIZE-1:0] ADDRESS;

instruction_decoder decoder(INSTRUCTION,OPCODE,REGISTER_1,REGISTER_2,REGISTER_DEST,SH_AMT,FUNC,IMMIDIATE,ADDRESS);

   initial
    begin
        # 2 // Latency for instruction register
        // Manually written
        INSTRUCTION = 32'b00000000_00000100_00000000_00000101; // loadi 4 0x05
        #2
        INSTRUCTION = 32'b00000000_00000010_00000000_00001001; // loadi 2 0x09
        #2
        INSTRUCTION = 32'b00000010_00000110_00000100_00000010; // add 6 4 2
        #2
        INSTRUCTION = 32'b00000001_00000000_00000000_00000110; // mov 0 6
        #2
        INSTRUCTION = 32'b00000000_00000001_00000000_00000001; // loadi 1 0x01
        #2
        INSTRUCTION = 32'b00000010_00000010_00000010_00000001; // add 2 2 1
        
    end

    initial begin
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("instruction_decoder_wavedata.vcd");
		$dumpvars(0, instruction_decoder_tb);
        // CLK = 1'b0;

        #20
        $finish;
    end
    
endmodule