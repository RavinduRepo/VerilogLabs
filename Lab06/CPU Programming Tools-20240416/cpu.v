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
`define JUMP_SIZE 8


`define OPCODE_END 24
`define REGISTER_1_END 8
`define REGISTER_2_END 0
`define REGISTER_DEST_END 16

`define SH_AMT_END 6
`define FUNC_END 0
`define IMMIDIATE_END 0
`define ADDRESS_END 0
`define JUMP_END 16

`define ALU_OP_SIZE 3



// Module for size 8 mux
module mux_module8(DATA1,DATA2,RESULT,SELECT);
    input [`REG_SIZE-1:0] DATA1;
    input [`REG_SIZE-1:0] DATA2;
    output reg [`REG_SIZE-1:0] RESULT; // if we want to use wire insted of reg , we woud have to use 'assign' to do that use internal_RESULT and assign to RESULT at the end
    input SELECT;

    always @(*) begin // Selecting
        RESULT = SELECT ? DATA2 : DATA1;
    end

endmodule

// Module for size 32 mux
module mux_module32(DATA1,DATA2,RESULT,SELECT);
    input [31:0] DATA1;
    input [31:0] DATA2;
    output reg [31:0] RESULT; // if we want to use wire insted of reg , we woud have to use 'assign' to do that use internal_RESULT and assign to RESULT at the end
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
module programme_counter(RESULT,NEXTRESULT,RESET,CLK);
    output reg [31:0] RESULT; 
    output reg [31:0] NEXTRESULT; 
    input RESET;
    input CLK;

    always @(posedge CLK) begin
        if (RESET) begin // Sets to zero of resset is  high
            RESULT <= #1 32'd0;
            NEXTRESULT <= #2 32'd4;
        end

        else begin // incrementing
            RESULT <= #1 NEXTRESULT;
            NEXTRESULT <= #2 NEXTRESULT + 32'd4;
        end
    end
    
endmodule


// Module for decoding instructions
module instruction_decoder(INSTRUCTION,OPCODE,REGISTER_1,REGISTER_2,REGISTER_DEST,IMMIDIATE,JUMPADDRESS);
    input [31:0] INSTRUCTION;
    output reg [`OPCODE_SIZE-1:0] OPCODE;
    output reg [`REG_ADDRESS_SIZE-1:0] REGISTER_1,REGISTER_2,REGISTER_DEST;
    output reg [`IMMIDIATE_SIZE-1:0] IMMIDIATE;
    output reg [`JUMP_SIZE-1:0] JUMPADDRESS;

    always @(INSTRUCTION) begin
        OPCODE = INSTRUCTION[`OPCODE_END + `OPCODE_SIZE : `OPCODE_END]; 
        REGISTER_1 = INSTRUCTION[`REGISTER_1_END + `REG_SIZE : `REGISTER_1_END];
        REGISTER_2 = INSTRUCTION[`REGISTER_2_END + `REG_SIZE : `REGISTER_2_END];
        REGISTER_DEST = INSTRUCTION[`REGISTER_DEST_END + `REG_SIZE : `REGISTER_DEST_END];
        IMMIDIATE = INSTRUCTION[`IMMIDIATE_END + `IMMIDIATE_SIZE : `IMMIDIATE_END];
        JUMPADDRESS = INSTRUCTION[`JUMP_END + `JUMP_SIZE : `JUMP_END];
    end

endmodule

// sign_extender
module sign_extender(INPUT,OUTPUT);
    input [`JUMP_SIZE-1:0] INPUT;
    output reg [31:0] OUTPUT;

    always @(INPUT) begin
        OUTPUT [31:`JUMP_SIZE] = 24'b0000_0000_0000_0000_0000_0000;
        OUTPUT [`JUMP_SIZE-1:0] = INPUT;
    end

endmodule

// left shift module
module left_shift(INPUT,OUTPUT);
    input [31:0] INPUT;
    output reg [31:0] OUTPUT;

    always @(INPUT) begin
        OUTPUT[31:2] = INPUT[29:0];
        OUTPUT[2:0] = 2'b00;
    end

endmodule

// jump_concatenate
module jump_concatenate(PCOUT,LEFTSHIFTEDJUMP,JUMPADDRESS);
    input [31:0] PCOUT;
    input [31:0] LEFTSHIFTEDJUMP;
    output reg [31:0] JUMPADDRESS;

    always @(PCOUT,LEFTSHIFTEDJUMP) begin
        JUMPADDRESS[31:28] = PCOUT[31:28];
        JUMPADDRESS[27:0] = LEFTSHIFTEDJUMP[27:0];
    end

endmodule

// and module for branch if equal instruction
module branch_and(DATA1,DATA2,RESULT);
    input DATA1;
    input DATA2;
    output RESULT;

    assign RESULT = DATA1 & DATA2;

endmodule

// add module for branch if equal instruction
module branch_add(PCOUT,LEFTSHIFTEDBRANCH,BRANCHADDRESS);
    input [31:0] PCOUT;
    input [31:0] LEFTSHIFTEDBRANCH;
    output reg [31:0] BRANCHADDRESS;

    always @(PCOUT,LEFTSHIFTEDBRANCH) begin
        BRANCHADDRESS = PCOUT + LEFTSHIFTEDBRANCH;
    end    
endmodule

// add, sub, and, or, mov, loadi
module control_unit(OPCODE,ALU_OP,ALU_SRC,REG_WRITE,TWOS_COMP,BRANCH_SELECT,JUMP_SELECT);
    input [`OPCODE_SIZE-1:0] OPCODE;
    output reg ALU_SRC,REG_WRITE,TWOS_COMP,BRANCH_SELECT,JUMP_SELECT;
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
            BRANCH_SELECT = 1'b0;
            JUMP_SELECT = 1'b0;
        end
        8'b00000001: // mov
        begin
            ALU_OP = 3'b000; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1;
            BRANCH_SELECT = 1'b0;
            JUMP_SELECT = 1'b0;     
        end   
        8'b00000010: // add
        begin
            ALU_OP = 3'b001; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1;
            BRANCH_SELECT = 1'b0;
            JUMP_SELECT = 1'b0;   
        end
        8'b00000011: // sub
        begin
            ALU_OP = 3'b001; //ALUOP COMMAND
            TWOS_COMP = 1'b1;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1;
            BRANCH_SELECT = 1'b0;
            JUMP_SELECT = 1'b0;  
        end
        8'b00000100: // and
        begin
            ALU_OP = 3'b010; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1;
            BRANCH_SELECT = 1'b0;
            JUMP_SELECT = 1'b0; 
        end  
        8'b00000101: // or
        begin
            ALU_OP = 3'b011; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b1; 
            BRANCH_SELECT = 1'b0;
            JUMP_SELECT = 1'b0;  
        end   
        8'b00000110: // j 
        begin
            ALU_OP = 3'b000; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b0; 
            BRANCH_SELECT = 1'b0;
            JUMP_SELECT = 1'b1;  
        end  
        8'b00000111: // beq
        begin
            ALU_OP = 3'b000; //ALUOP COMMAND
            TWOS_COMP = 1'b0;
            ALU_SRC = 1'b0;
            REG_WRITE = 1'b0; 
            BRANCH_SELECT = 1'b1;
            JUMP_SELECT = 1'b0;  
        end 
        endcase
    end 

endmodule

	// char *op_j		= "00000110";
	// char *op_beq	= "00000111";

module cpu(PCOUT, INSTRUCTION, CLK, RESET);
    input wire [31:0] INSTRUCTION;
    input wire CLK;
    input wire RESET;

    //programe counter
    output wire [31:0] PCOUT;
    output wire [31:0] NEXTPCOUT;

    //instruction_decoder
    wire [`IMMIDIATE_SIZE-1:0] IMMIDIATE;
    wire [`REG_ADDRESS_SIZE-1:0] READREG2;
    wire [`REG_ADDRESS_SIZE-1:0] READREG1;
    wire [`REG_ADDRESS_SIZE-1:0] WRITEREG;
    wire [`OPCODE_SIZE-1:0] OPCODE;
    wire [`JUMP_SIZE-1:0] JUMPINSTRUCTION;

    //sign_extender
    wire [31:0] SIGNEXTENDEDJUMP;
    wire [31:0] SIGNEXTENDEDBRANCH;

    //left_shift
    wire [31:0] LEFTSHIFTEDJUMP;
    wire [31:0] LEFTSHIFTEDBRANCH;

    //jump_concatenator
    wire [31:0] JUMPADDRESS;

    //branch_add
    wire [31:0] BRANCHADDRESS;

    //branch_and
    wire ZERO_and_BRANCHSELECT;

    //control_unit
    wire WRITEENABLE;
    wire TWOS_COMP_SELECT;
    wire IMMIDIATE_SELECT;
    wire [`ALU_OP_SIZE-1:0] ALUOP;
    wire BRANCH_SELECT;
    wire JUMP_SELECT;

    //register_file
    wire [`REG_SIZE-1:0] REGOUT2;
    wire [`REG_SIZE-1:0] REGOUT1;

    //twos_compliment
    wire [`REG_SIZE-1:0] TWOS_COMP;

    //mux
    wire [`REG_SIZE-1:0] TWOS_COMP_SELECTED;
    wire [`REG_SIZE-1:0] IMMIDIATE_SELECTED;
    wire [31:0] BRANCH_SELECTED;
    wire [31:0] JUMP_SELECTED;

    //alu
    wire [`REG_SIZE-1:0] ALURESULT;
    wire ZERO;

    programme_counter pc(PCOUT,NEXTPCOUT,RESET,CLK); // The programme counter
    instruction_decoder instruction_decoder(INSTRUCTION,OPCODE,READREG1,READREG2,WRITEREG,IMMIDIATE,JUMPINSTRUCTION);   // The instruction decorder
    
    sign_extender sign_extender_for_jump(JUMPINSTRUCTION,SIGNEXTENDEDJUMP);     // sign extend for jump instruction
    left_shift left_shift_for_jump(SIGNEXTENDEDJUMP,LEFTSHIFTEDJUMP);   // left shift for jump instruction 
    jump_concatenate jump_concatenate(NEXTPCOUT,LEFTSHIFTEDJUMP,JUMPADDRESS);   // jump concatenator

    sign_extender sign_extender_for_branch(IMMIDIATE,SIGNEXTENDEDBRANCH);   // sign extended for branch imidiate value
    left_shift left_shift_for_branch(SIGNEXTENDEDBRANCH,LEFTSHIFTEDBRANCH); // left shift for branch iimidiate value
    branch_add branch_add(NEXTPCOUT,LEFTSHIFTEDBRANCH,BRANCHADDRESS);    // adding address to PC+4 for branch instruction

    control_unit control_unit(OPCODE,ALUOP,IMMIDIATE_SELECT,WRITEENABLE,TWOS_COMP_SELECT,BRANCH_SELECT,JUMP_SELECT);  // Control unit

    reg_file reg_file(ALURESULT,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLK,RESET);  // Register file
    twos_complement twoscomp(REGOUT2,TWOS_COMP);    // Twos complement 

    mux_module8 twos_complement_mux(REGOUT2,TWOS_COMP,TWOS_COMP_SELECTED,TWOS_COMP_SELECT);      // mux to select the two's complement
    mux_module8 alu_immidiate_mux(TWOS_COMP_SELECTED,IMMIDIATE,IMMIDIATE_SELECTED,IMMIDIATE_SELECT);     // Mux to select the immidate value from the instruction
    
    branch_and branch_and(BRANCH_SELECT,ZERO,ZERO_and_BRANCHSELECT);    // and gate for if_Zero and Branch control signal
    mux_module32 branch_select_mux(PCOUT,BRANCHADDRESS,BRANCH_SELECTED,ZERO_and_BRANCHSELECT); // selcting mux whether to branch or not

    mux_module32 jump_select_mux(BRANCH_SELECTED,JUMPADDRESS,JUMP_SELECTED,JUMP_SELECT); // selcting mux whether to branch or not

    alu alu(REGOUT1,IMMIDIATE_SELECTED,ALURESULT,ALUOP,ZERO);    // The ALU 

endmodule