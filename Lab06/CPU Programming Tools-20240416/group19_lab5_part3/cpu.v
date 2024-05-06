`include "alu.v"
`include "reg_file.v"

// Variables defined if have to change later(No effect when synthesising since all replace by it's value)
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

// Module for muxs
module mux_module(DATA1,DATA2,RESULT,SELECT);
    input [`REG_SIZE-1:0] DATA1;
    input [`REG_SIZE-1:0] DATA2;
    output reg [`REG_SIZE-1:0] RESULT; // if we want to use wire insted of reg , we woud have to use 'assign' to do that use internal_RESULT and assign to RESULT at the end
    input SELECT;

    always @(*) begin // Selecting
        RESULT = SELECT ? DATA2 : DATA1;
    end

endmodule

// Module for Two's complement
module twos_complement(DATA,RESULT);
    input [`REG_SIZE-1:0] DATA;
    output reg [`REG_SIZE-1:0] RESULT;

    always @(DATA) begin
        #1 RESULT = ~DATA + 1'b1; // Convering to the two's complement
    end

endmodule

// Programme counter module
module programme_counter(RESULT,RESET,CLK);
    output reg [31:0] RESULT; 
    input RESET;
    input CLK;

    always @(posedge CLK) begin
        #1
        if (RESET) begin // Sets to zero of resset is  high
            RESULT <= 32'd0;
        end

        else begin // incrementing
            RESULT <= RESULT + 32'd4;
        end
    end
    
endmodule


// Module for decoding instructions
module instruction_decoder(INSTRUCTION,OPCODE,REGISTER_1,REGISTER_2,REGISTER_DEST,IMMIDIATE);
    input [31:0] INSTRUCTION;
    output reg [`OPCODE_SIZE-1:0] OPCODE;
    output reg [`REG_ADDRESS_SIZE-1:0] REGISTER_1,REGISTER_2,REGISTER_DEST;
    output reg [`IMMIDIATE_SIZE-1:0] IMMIDIATE;

    always @(INSTRUCTION) begin
        OPCODE = INSTRUCTION[`OPCODE_END + `OPCODE_SIZE : `OPCODE_END]; 
        REGISTER_1 = INSTRUCTION[`REGISTER_1_END + `REG_SIZE : `REGISTER_1_END];
        REGISTER_2 = INSTRUCTION[`REGISTER_2_END + `REG_SIZE : `REGISTER_2_END];
        REGISTER_DEST = INSTRUCTION[`REGISTER_DEST_END + `REG_SIZE : `REGISTER_DEST_END];
        IMMIDIATE = INSTRUCTION[`IMMIDIATE_END + `IMMIDIATE_SIZE : `IMMIDIATE_END];
    end

endmodule


// add, sub, and, or, mov, loadi
module control_unit(OPCODE,ALU_OP,ALU_SRC,REG_WRITE,TWOS_COMP);
    input [`OPCODE_SIZE-1:0] OPCODE;
    output reg ALU_SRC,REG_WRITE,TWOS_COMP;
    output reg [`ALU_OP_SIZE-1:0] ALU_OP;

    // always block * to run the block whenever any input changes  
    always @(*)
    begin
        #1 // Decorder delay
        case (OPCODE) 
        8'b00000000: // loadi
        begin
            ALU_OP = 3'b000; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b1;
            REG_WRITE = 1'b1;
        end
        8'b00000001: // mov
        begin
            ALU_OP = 3'b000; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1;     
        end   
        8'b00000010: // add
        begin
            ALU_OP = 3'b001; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1;   
        end
        8'b00000011: // sub
        begin
            ALU_OP = 3'b001; //ALUOP COMMAND
            TWOS_COMP = 1'b1;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1;   
        end
        8'b00000100: // and
        begin
            ALU_OP = 3'b010; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1;  
        end  
        8'b00000101: // or
        begin
            ALU_OP = 3'b011; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1;   
        end  
        endcase
    end 

endmodule


module cpu(PCOUT, INSTRUCTION, CLK, RESET);
    input wire [31:0] INSTRUCTION;
    input wire CLK;
    input wire RESET;
    output wire [31:0] PCOUT;

    //instruction_decoder
    wire [`REG_SIZE-1:0] IMMIDIATE;
    wire [`REG_ADDRESS_SIZE-1:0] READREG2;
    wire [`REG_ADDRESS_SIZE-1:0] READREG1;
    wire [`REG_ADDRESS_SIZE-1:0] WRITEREG;
    wire [`OPCODE_SIZE-1:0] OPCODE;

    //control_unit
    wire WRITEENABLE;
    wire TWOS_COMP_SELECT;
    wire IMMIDIATE_SELECT;
    wire [`ALU_OP_SIZE-1:0] ALUOP;

    //register_file
    wire [`REG_SIZE-1:0] REGOUT2;
    wire [`REG_SIZE-1:0] REGOUT1;

    //twos_compliment
    wire [`REG_SIZE-1:0] TWOS_COMP;

    //mux
    wire [`REG_SIZE-1:0] TWOS_COMP_SELECTED;
    wire [`REG_SIZE-1:0] IMMIDIATE_SELECTED;

    //alu
    wire [`REG_SIZE-1:0] ALURESULT;

    programme_counter pc(PCOUT,RESET,CLK); // The programme counter
    instruction_decoder instruction_decoder(INSTRUCTION,OPCODE,READREG1,READREG2,WRITEREG,IMMIDIATE);   // The instruction decorder
    control_unit control_unit(OPCODE,ALUOP,IMMIDIATE_SELECT,WRITEENABLE,TWOS_COMP_SELECT);  //Control unit

    reg_file reg_file(ALURESULT,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLK,RESET);  // Register file
    twos_complement twoscomp(REGOUT2,TWOS_COMP);    // Twos complement 
    mux_module twos_complement_mux(REGOUT2,TWOS_COMP,TWOS_COMP_SELECTED,TWOS_COMP_SELECT);      // mux to select the two's complement
    mux_module alu_immidiate_mux(TWOS_COMP_SELECTED,IMMIDIATE,IMMIDIATE_SELECTED,IMMIDIATE_SELECT);     // Mux to select the immidate value from the instruction
    alu alu(REGOUT1,IMMIDIATE_SELECTED,ALURESULT,ALUOP);    // The ALU 

endmodule