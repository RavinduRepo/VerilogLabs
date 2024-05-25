`define REG_SIZE 8
`define REG_ADDRESS_SIZE 3


module mov_module (DATA2,RESULT);
    input [`REG_SIZE-1:0] DATA2;
    output [`REG_SIZE-1:0] RESULT;

    assign RESULT = DATA2;

endmodule

module add_module (DATA1,DATA2,RESULT);
    input [`REG_SIZE-1:0] DATA1;
    input [`REG_SIZE-1:0] DATA2;
    output reg [`REG_SIZE-1:0] RESULT;
    
    always @(*) 
    begin   // add - sub
    if (DATA2 < 0)  // or we can use (DATA2[7]) as the condition
        RESULT = DATA1 - DATA2;
    else
        RESULT = DATA1 + DATA2;
    end

endmodule

module and_module (DATA1,DATA2,RESULT);
    input [`REG_SIZE-1:0] DATA1;
    input [`REG_SIZE-1:0] DATA2;
    output [`REG_SIZE-1:0] RESULT;

    assign RESULT = DATA1 & DATA2;

endmodule

module or_module (DATA1,DATA2,RESULT);
    input [`REG_SIZE-1:0] DATA1;
    input [`REG_SIZE-1:0] DATA2;
    output [`REG_SIZE-1:0] RESULT;

    assign RESULT = DATA1 | DATA2;

endmodule

module mult_module (DATA1, DATA2, RESULT);

//Input and output port declaration
	input [7:0] DATA1, DATA2;
	output [7:0] RESULT;
	
	//Carry bits for intermediate sums
	wire C0 [5:0];
	wire C1 [4:0];
	wire C2 [3:0];
	wire C3 [2:0];
	wire C4 [1:0];
	wire C5;
	
	//Intermediate sums
	wire sum0 [5:0];
	wire sum1 [4:0];
	wire sum2 [3:0];
	wire sum3 [2:0];
	wire sum4 [1:0];
	wire sum5;
	
	// To store result before output
	wire [7:0] OUT;
	
	//First bit of RESULT can be directly set
	assign OUT[0] = DATA2[0] & DATA1[0];	
	
	
	//Full Adder layers to calculate the result by shifting and adding
	//Layer 0
	full_adder_module FA0_0(DATA2[0] & DATA1[1], DATA2[1] & DATA1[0], 1'b0, OUT[1], C0[0]);
	full_adder_module FA0_1(DATA2[0] & DATA1[2], DATA2[1] & DATA1[1], C0[0], sum0[0], C0[1]);
	full_adder_module FA0_2(DATA2[0] & DATA1[3], DATA2[1] & DATA1[2], C0[1], sum0[1], C0[2]);
	full_adder_module FA0_3(DATA2[0] & DATA1[4], DATA2[1] & DATA1[3], C0[2], sum0[2], C0[3]);
	full_adder_module FA0_4(DATA2[0] & DATA1[5], DATA2[1] & DATA1[4], C0[3], sum0[3], C0[4]);
	full_adder_module FA0_5(DATA2[0] & DATA1[6], DATA2[1] & DATA1[5], C0[4], sum0[4], C0[5]);
	full_adder_module FA0_6(DATA2[0] & DATA1[7], DATA2[1] & DATA1[6], C0[5], sum0[5], );
	
	//Layer 1
	full_adder_module FA1_0(sum0[0], DATA2[2] & DATA1[0], 1'b0, OUT[2], C1[0]);
	full_adder_module FA1_1(sum0[1], DATA2[2] & DATA1[1], C1[0], sum1[0], C1[1]);
	full_adder_module FA1_2(sum0[2], DATA2[2] & DATA1[2], C1[1], sum1[1], C1[2]);
	full_adder_module FA1_3(sum0[3], DATA2[2] & DATA1[3], C1[2], sum1[2], C1[3]);
	full_adder_module FA1_4(sum0[4], DATA2[2] & DATA1[4], C1[3], sum1[3], C1[4]);
	full_adder_module FA1_5(sum0[5], DATA2[2] & DATA1[5], C1[4], sum1[4], );
	
	//Layer 2
	full_adder_module FA2_0(sum1[0], DATA2[3] & DATA1[0], 1'b0, OUT[3], C2[0]);
	full_adder_module FA2_1(sum1[1], DATA2[3] & DATA1[1], C2[0], sum2[0], C2[1]);
	full_adder_module FA2_2(sum1[2], DATA2[3] & DATA1[2], C2[1], sum2[1], C2[2]);
	full_adder_module FA2_3(sum1[3], DATA2[3] & DATA1[3], C2[2], sum2[2], C2[3]);
	full_adder_module FA2_4(sum1[4], DATA2[3] & DATA1[4], C2[3], sum2[3], );
	
	//Layer 3
	full_adder_module FA3_0(sum2[0], DATA2[4] & DATA1[0], 1'b0, OUT[4], C3[0]);
	full_adder_module FA3_1(sum2[1], DATA2[4] & DATA1[1], C3[0], sum3[0], C3[1]);
	full_adder_module FA3_2(sum2[2], DATA2[4] & DATA1[2], C3[1], sum3[1], C3[2]);
	full_adder_module FA3_3(sum2[3], DATA2[4] & DATA1[3], C3[2], sum3[2], );
	
	//Layer 4
	full_adder_module FA4_0(sum3[0], DATA2[5] & DATA1[0], 1'b0, OUT[5], C4[0]);
	full_adder_module FA4_1(sum3[1], DATA2[5] & DATA1[1], C4[0], sum4[0], C4[1]);
	full_adder_module FA4_2(sum3[2], DATA2[5] & DATA1[2], C4[1], sum4[1], );
	
	//Layer 5
	full_adder_module FA5_0(sum4[0], DATA2[6] & DATA1[0], 1'b0, OUT[6], C5);
	full_adder_module FA5_1(sum4[1], DATA2[6] & DATA1[1], C5, sum5, );
	
	//Layer 6
	full_adder_module FA6_0(sum5, DATA2[7] & DATA1[0], 1'b0, OUT[7], );
	
	//Sending out result after #3 time unit delay
	assign #3 RESULT = OUT;

endmodule


//Module for full Adder
module full_adder_module(A, B, C, SUM, CARRY);

	//Input and output port declaration
	input A, B, C;
	output SUM, CARRY;
	
	//Combinational logic for SUM and CARRY bit outputs
	assign SUM = (A ^ B ^ C);
	assign CARRY = (A & B) + (C & (A ^ B));

     
endmodule

// Module for size 8 mux
module mux_1bit_2x1_module(DATA1,DATA2,RESULT,SELECT);
    input DATA1;
    input DATA2;
    output reg RESULT; // if we want to use wire insted of reg , we woud have to use 'assign' to do that use internal_RESULT and assign to RESULT at the end
    input SELECT;

    always @(*) begin // Selecting
        RESULT = SELECT ? DATA2 : DATA1;
    end

endmodule

module logical_shift_module (DATA, SHIFTAMOUNT, RESULT);
    input [`REG_SIZE-1:0] DATA;
    input [`REG_SIZE-1:0] SHIFTAMOUNT;
    reg [`REG_SIZE-1:0] OFFSET;
    output reg [`REG_SIZE-1:0] RESULT;
    wire [7:0] CALCULATE_LS [2:0];
    wire [7:0] CALCULATE_RS [2:0];

    // left shift calculations
    // MUX Layer 1
    mux_1bit_2x1_module LSlayer10(DATA[0],1'b0,CALCULATE_LS[0][0],OFFSET[0]);
    mux_1bit_2x1_module LSlayer11(DATA[1],DATA[0],CALCULATE_LS[0][1],OFFSET[0]);
    mux_1bit_2x1_module LSlayer12(DATA[2],DATA[1],CALCULATE_LS[0][2],OFFSET[0]);
    mux_1bit_2x1_module LSlayer13(DATA[3],DATA[2],CALCULATE_LS[0][3],OFFSET[0]);
    mux_1bit_2x1_module LSlayer14(DATA[4],DATA[3],CALCULATE_LS[0][4],OFFSET[0]);
    mux_1bit_2x1_module LSlayer15(DATA[5],DATA[4],CALCULATE_LS[0][5],OFFSET[0]);
    mux_1bit_2x1_module LSlayer16(DATA[6],DATA[5],CALCULATE_LS[0][6],OFFSET[0]);
    mux_1bit_2x1_module LSlayer17(DATA[7],DATA[6],CALCULATE_LS[0][7],OFFSET[0]);

    // MUX Layer 2
    mux_1bit_2x1_module LSlayer20(CALCULATE_LS[0][0],1'b0,CALCULATE_LS[1][0],OFFSET[1]);    
    mux_1bit_2x1_module LSlayer21(CALCULATE_LS[0][1],1'b0,CALCULATE_LS[1][1],OFFSET[1]);
    mux_1bit_2x1_module LSlayer22(CALCULATE_LS[0][2],CALCULATE_LS[0][0],CALCULATE_LS[1][2],OFFSET[1]);
    mux_1bit_2x1_module LSlayer23(CALCULATE_LS[0][3],CALCULATE_LS[0][1],CALCULATE_LS[1][3],OFFSET[1]);
    mux_1bit_2x1_module LSlayer24(CALCULATE_LS[0][4],CALCULATE_LS[0][2],CALCULATE_LS[1][4],OFFSET[1]);
    mux_1bit_2x1_module LSlayer25(CALCULATE_LS[0][5],CALCULATE_LS[0][3],CALCULATE_LS[1][5],OFFSET[1]);
    mux_1bit_2x1_module LSlayer26(CALCULATE_LS[0][6],CALCULATE_LS[0][4],CALCULATE_LS[1][6],OFFSET[1]);
    mux_1bit_2x1_module LSlayer27(CALCULATE_LS[0][7],CALCULATE_LS[0][5],CALCULATE_LS[1][7],OFFSET[1]);

    // MUX Layer 3
    mux_1bit_2x1_module LSlayer30(CALCULATE_LS[1][0],1'b0,CALCULATE_LS[2][0],OFFSET[2]);    
    mux_1bit_2x1_module LSlayer31(CALCULATE_LS[1][1],1'b0,CALCULATE_LS[2][1],OFFSET[2]);
    mux_1bit_2x1_module LSlayer32(CALCULATE_LS[1][2],1'b0,CALCULATE_LS[2][2],OFFSET[2]);
    mux_1bit_2x1_module LSlayer33(CALCULATE_LS[1][3],1'b0,CALCULATE_LS[2][3],OFFSET[2]);
    mux_1bit_2x1_module LSlayer34(CALCULATE_LS[1][4],CALCULATE_LS[1][0],CALCULATE_LS[2][4],OFFSET[2]);
    mux_1bit_2x1_module LSlayer35(CALCULATE_LS[1][5],CALCULATE_LS[1][1],CALCULATE_LS[2][5],OFFSET[2]);
    mux_1bit_2x1_module LSlayer36(CALCULATE_LS[1][6],CALCULATE_LS[1][2],CALCULATE_LS[2][6],OFFSET[2]);
    mux_1bit_2x1_module LSlayer37(CALCULATE_LS[1][7],CALCULATE_LS[1][3],CALCULATE_LS[2][7],OFFSET[2]);



    // right shift calculations
    // MUX Layer 1
    mux_1bit_2x1_module RSlayer10(DATA[7],1'b0,CALCULATE_RS[0][7],OFFSET[0]);
    mux_1bit_2x1_module RSlayer11(DATA[6],DATA[7],CALCULATE_RS[0][6],OFFSET[0]);
    mux_1bit_2x1_module RSlayer12(DATA[5],DATA[6],CALCULATE_RS[0][5],OFFSET[0]);
    mux_1bit_2x1_module RSlayer13(DATA[4],DATA[5],CALCULATE_RS[0][4],OFFSET[0]);
    mux_1bit_2x1_module RSlayer14(DATA[3],DATA[4],CALCULATE_RS[0][3],OFFSET[0]);
    mux_1bit_2x1_module RSlayer15(DATA[2],DATA[3],CALCULATE_RS[0][2],OFFSET[0]);
    mux_1bit_2x1_module RSlayer16(DATA[1],DATA[2],CALCULATE_RS[0][1],OFFSET[0]);
    mux_1bit_2x1_module RSlayer17(DATA[0],DATA[1],CALCULATE_RS[0][0],OFFSET[0]);

    // MUX Layer 2
    mux_1bit_2x1_module RSlayer20(CALCULATE_RS[0][7],1'b0,CALCULATE_RS[1][7],OFFSET[1]);    
    mux_1bit_2x1_module RSlayer21(CALCULATE_RS[0][6],1'b0,CALCULATE_RS[1][6],OFFSET[1]);
    mux_1bit_2x1_module RSlayer22(CALCULATE_RS[0][5],CALCULATE_RS[0][7],CALCULATE_RS[1][5],OFFSET[1]);
    mux_1bit_2x1_module RSlayer23(CALCULATE_RS[0][4],CALCULATE_RS[0][6],CALCULATE_RS[1][4],OFFSET[1]);
    mux_1bit_2x1_module RSlayer24(CALCULATE_RS[0][3],CALCULATE_RS[0][5],CALCULATE_RS[1][3],OFFSET[1]);
    mux_1bit_2x1_module RSlayer25(CALCULATE_RS[0][2],CALCULATE_RS[0][4],CALCULATE_RS[1][2],OFFSET[1]);
    mux_1bit_2x1_module RSlayer26(CALCULATE_RS[0][1],CALCULATE_RS[0][3],CALCULATE_RS[1][1],OFFSET[1]);
    mux_1bit_2x1_module RSlayer27(CALCULATE_RS[0][0],CALCULATE_RS[0][2],CALCULATE_RS[1][0],OFFSET[1]);

    // MUX Layer 3
    mux_1bit_2x1_module RSlayer30(CALCULATE_RS[1][7],1'b0,CALCULATE_RS[2][7],OFFSET[2]);    
    mux_1bit_2x1_module RSlayer31(CALCULATE_RS[1][6],1'b0,CALCULATE_RS[2][6],OFFSET[2]);
    mux_1bit_2x1_module RSlayer32(CALCULATE_RS[1][5],1'b0,CALCULATE_RS[2][5],OFFSET[2]);
    mux_1bit_2x1_module RSlayer33(CALCULATE_RS[1][4],1'b0,CALCULATE_RS[2][4],OFFSET[2]);
    mux_1bit_2x1_module RSlayer34(CALCULATE_RS[1][3],CALCULATE_RS[1][7],CALCULATE_RS[2][3],OFFSET[2]);
    mux_1bit_2x1_module RSlayer35(CALCULATE_RS[1][2],CALCULATE_RS[1][6],CALCULATE_RS[2][2],OFFSET[2]);
    mux_1bit_2x1_module RSlayer36(CALCULATE_RS[1][1],CALCULATE_RS[1][5],CALCULATE_RS[2][1],OFFSET[2]);
    mux_1bit_2x1_module RSlayer37(CALCULATE_RS[1][0],CALCULATE_RS[1][4],CALCULATE_RS[2][0],OFFSET[2]);

    // setting the result
    always @(*) begin

        if (SHIFTAMOUNT[7]) begin // Right shift
            OFFSET = -SHIFTAMOUNT;
            RESULT = CALCULATE_RS[2];
            // If SHIFTAMOUNT >= 8'd8 (or 8'b00000111) result is 8'd0 (or 8'b00000000)
            if (OFFSET >= 8'd8) begin
                RESULT = 8'd0;
            end
        end
        else if (!SHIFTAMOUNT[7]) begin // Left shift
            OFFSET = SHIFTAMOUNT;
            RESULT = CALCULATE_LS[2];
            // If SHIFTAMOUNT >= 8'd8 (or 8'b00000111) result is 8'd0 (or 8'b00000000)
            if (OFFSET >= 8'd8) begin
                RESULT = 8'd0;
            end
        end

    end


endmodule

module arithmatic_shift_module (DATA, SHIFTAMOUNT, RESULT);
    input [`REG_SIZE-1:0] DATA;
    input [`REG_SIZE-1:0] SHIFTAMOUNT;
    reg [`REG_SIZE-1:0] OFFSET;
    output reg [`REG_SIZE-1:0] RESULT;
    wire [7:0] CALCULATE_LS [2:0];
    wire [7:0] CALCULATE_RS [2:0];

    // left shift calculations
    // MUX Layer 1
    mux_1bit_2x1_module LSlayer10(DATA[0],1'b0,CALCULATE_LS[0][0],OFFSET[0]);
    mux_1bit_2x1_module LSlayer11(DATA[1],DATA[0],CALCULATE_LS[0][1],OFFSET[0]);
    mux_1bit_2x1_module LSlayer12(DATA[2],DATA[1],CALCULATE_LS[0][2],OFFSET[0]);
    mux_1bit_2x1_module LSlayer13(DATA[3],DATA[2],CALCULATE_LS[0][3],OFFSET[0]);
    mux_1bit_2x1_module LSlayer14(DATA[4],DATA[3],CALCULATE_LS[0][4],OFFSET[0]);
    mux_1bit_2x1_module LSlayer15(DATA[5],DATA[4],CALCULATE_LS[0][5],OFFSET[0]);
    mux_1bit_2x1_module LSlayer16(DATA[6],DATA[5],CALCULATE_LS[0][6],OFFSET[0]);
    mux_1bit_2x1_module LSlayer17(DATA[7],DATA[7],CALCULATE_LS[0][7],OFFSET[0]);

    // MUX Layer 2
    mux_1bit_2x1_module LSlayer20(CALCULATE_LS[0][0],1'b0,CALCULATE_LS[1][0],OFFSET[1]);    
    mux_1bit_2x1_module LSlayer21(CALCULATE_LS[0][1],1'b0,CALCULATE_LS[1][1],OFFSET[1]);
    mux_1bit_2x1_module LSlayer22(CALCULATE_LS[0][2],CALCULATE_LS[0][0],CALCULATE_LS[1][2],OFFSET[1]);
    mux_1bit_2x1_module LSlayer23(CALCULATE_LS[0][3],CALCULATE_LS[0][1],CALCULATE_LS[1][3],OFFSET[1]);
    mux_1bit_2x1_module LSlayer24(CALCULATE_LS[0][4],CALCULATE_LS[0][2],CALCULATE_LS[1][4],OFFSET[1]);
    mux_1bit_2x1_module LSlayer25(CALCULATE_LS[0][5],CALCULATE_LS[0][3],CALCULATE_LS[1][5],OFFSET[1]);
    mux_1bit_2x1_module LSlayer26(CALCULATE_LS[0][6],CALCULATE_LS[0][4],CALCULATE_LS[1][6],OFFSET[1]);
    mux_1bit_2x1_module LSlayer27(CALCULATE_LS[0][7],CALCULATE_LS[0][7],CALCULATE_LS[1][7],OFFSET[1]);

    // MUX Layer 3
    mux_1bit_2x1_module LSlayer30(CALCULATE_LS[1][0],1'b0,CALCULATE_LS[2][0],OFFSET[2]);    
    mux_1bit_2x1_module LSlayer31(CALCULATE_LS[1][1],1'b0,CALCULATE_LS[2][1],OFFSET[2]);
    mux_1bit_2x1_module LSlayer32(CALCULATE_LS[1][2],1'b0,CALCULATE_LS[2][2],OFFSET[2]);
    mux_1bit_2x1_module LSlayer33(CALCULATE_LS[1][3],1'b0,CALCULATE_LS[2][3],OFFSET[2]);
    mux_1bit_2x1_module LSlayer34(CALCULATE_LS[1][4],CALCULATE_LS[1][0],CALCULATE_LS[2][4],OFFSET[2]);
    mux_1bit_2x1_module LSlayer35(CALCULATE_LS[1][5],CALCULATE_LS[1][1],CALCULATE_LS[2][5],OFFSET[2]);
    mux_1bit_2x1_module LSlayer36(CALCULATE_LS[1][6],CALCULATE_LS[1][2],CALCULATE_LS[2][6],OFFSET[2]);
    mux_1bit_2x1_module LSlayer37(CALCULATE_LS[1][7],CALCULATE_LS[1][7],CALCULATE_LS[2][7],OFFSET[2]);

    // right shift calculations
    // MUX Layer 1
    mux_1bit_2x1_module RSlayer10(DATA[7],DATA[7],CALCULATE_RS[0][7],OFFSET[0]);
    mux_1bit_2x1_module RSlayer11(DATA[6],DATA[7],CALCULATE_RS[0][6],OFFSET[0]);
    mux_1bit_2x1_module RSlayer12(DATA[5],DATA[6],CALCULATE_RS[0][5],OFFSET[0]);
    mux_1bit_2x1_module RSlayer13(DATA[4],DATA[5],CALCULATE_RS[0][4],OFFSET[0]);
    mux_1bit_2x1_module RSlayer14(DATA[3],DATA[4],CALCULATE_RS[0][3],OFFSET[0]);
    mux_1bit_2x1_module RSlayer15(DATA[2],DATA[3],CALCULATE_RS[0][2],OFFSET[0]);
    mux_1bit_2x1_module RSlayer16(DATA[1],DATA[2],CALCULATE_RS[0][1],OFFSET[0]);
    mux_1bit_2x1_module RSlayer17(DATA[0],DATA[1],CALCULATE_RS[0][0],OFFSET[0]);

    // MUX Layer 2
    mux_1bit_2x1_module RSlayer20(CALCULATE_RS[0][7],CALCULATE_RS[0][7],CALCULATE_RS[1][7],OFFSET[1]);    
    mux_1bit_2x1_module RSlayer21(CALCULATE_RS[0][6],CALCULATE_RS[0][7],CALCULATE_RS[1][6],OFFSET[1]);
    mux_1bit_2x1_module RSlayer22(CALCULATE_RS[0][5],CALCULATE_RS[0][7],CALCULATE_RS[1][5],OFFSET[1]);
    mux_1bit_2x1_module RSlayer23(CALCULATE_RS[0][4],CALCULATE_RS[0][6],CALCULATE_RS[1][4],OFFSET[1]);
    mux_1bit_2x1_module RSlayer24(CALCULATE_RS[0][3],CALCULATE_RS[0][5],CALCULATE_RS[1][3],OFFSET[1]);
    mux_1bit_2x1_module RSlayer25(CALCULATE_RS[0][2],CALCULATE_RS[0][4],CALCULATE_RS[1][2],OFFSET[1]);
    mux_1bit_2x1_module RSlayer26(CALCULATE_RS[0][1],CALCULATE_RS[0][3],CALCULATE_RS[1][1],OFFSET[1]);
    mux_1bit_2x1_module RSlayer27(CALCULATE_RS[0][0],CALCULATE_RS[0][2],CALCULATE_RS[1][0],OFFSET[1]);

    // MUX Layer 3
    mux_1bit_2x1_module RSlayer30(CALCULATE_RS[1][7],CALCULATE_RS[1][7],CALCULATE_RS[2][7],OFFSET[2]);    
    mux_1bit_2x1_module RSlayer31(CALCULATE_RS[1][6],CALCULATE_RS[1][7],CALCULATE_RS[2][6],OFFSET[2]);
    mux_1bit_2x1_module RSlayer32(CALCULATE_RS[1][5],CALCULATE_RS[1][7],CALCULATE_RS[2][5],OFFSET[2]);
    mux_1bit_2x1_module RSlayer33(CALCULATE_RS[1][4],CALCULATE_RS[1][7],CALCULATE_RS[2][4],OFFSET[2]);
    mux_1bit_2x1_module RSlayer34(CALCULATE_RS[1][3],CALCULATE_RS[1][7],CALCULATE_RS[2][3],OFFSET[2]);
    mux_1bit_2x1_module RSlayer35(CALCULATE_RS[1][2],CALCULATE_RS[1][6],CALCULATE_RS[2][2],OFFSET[2]);
    mux_1bit_2x1_module RSlayer36(CALCULATE_RS[1][1],CALCULATE_RS[1][5],CALCULATE_RS[2][1],OFFSET[2]);
    mux_1bit_2x1_module RSlayer37(CALCULATE_RS[1][0],CALCULATE_RS[1][4],CALCULATE_RS[2][0],OFFSET[2]);

    // setting the result
    always @(*) begin

        if (SHIFTAMOUNT[7]) begin // Right shift
            OFFSET = -SHIFTAMOUNT;
            #2
            RESULT = CALCULATE_RS[2];
            // If SHIFTAMOUNT >= 8'd8 (or 8'b00000111) result is 8'd0 (or 8'b00000000)
            if (OFFSET >= 8'd8) begin
                RESULT[6:0] = 7'd0;
                RESULT[7] = DATA[7];
            end
        end
        else if (!SHIFTAMOUNT[7]) begin // Left shift
            OFFSET = SHIFTAMOUNT;
            #2
            RESULT = CALCULATE_LS[2];
            // If SHIFTAMOUNT >= 8'd8 (or 8'b00000111) result is 8'd0 (or 8'b00000000)
            if (OFFSET >= 8'd8) begin
                RESULT[6:0] = 7'd0;
                RESULT[7] = DATA[7];
            end
        end

    end


endmodule

module rotate_module(DATA, ROTATEAMOUNT, RESULT);
    input [`REG_SIZE-1:0] DATA;
    input [`REG_SIZE-1:0] ROTATEAMOUNT;
    reg [`REG_SIZE-1:0] OFFSET;
    output reg [`REG_SIZE-1:0] RESULT;
    wire [7:0] CALCULATE_LR [2:0];
    wire [7:0] CALCULATE_RR [2:0];

    // left rotate calculations
    // MUX Layer 1
    mux_1bit_2x1_module LRlayer10(DATA[0],DATA[7],CALCULATE_LR[0][0],OFFSET[0]);
    mux_1bit_2x1_module LRlayer11(DATA[1],DATA[0],CALCULATE_LR[0][1],OFFSET[0]);
    mux_1bit_2x1_module LRlayer12(DATA[2],DATA[1],CALCULATE_LR[0][2],OFFSET[0]);
    mux_1bit_2x1_module LRlayer13(DATA[3],DATA[2],CALCULATE_LR[0][3],OFFSET[0]);
    mux_1bit_2x1_module LRlayer14(DATA[4],DATA[3],CALCULATE_LR[0][4],OFFSET[0]);
    mux_1bit_2x1_module LRlayer15(DATA[5],DATA[4],CALCULATE_LR[0][5],OFFSET[0]);
    mux_1bit_2x1_module LRlayer16(DATA[6],DATA[5],CALCULATE_LR[0][6],OFFSET[0]);
    mux_1bit_2x1_module LRlayer17(DATA[7],DATA[6],CALCULATE_LR[0][7],OFFSET[0]);

    // MUX Layer 2
    mux_1bit_2x1_module LRlayer20(CALCULATE_LR[0][0],CALCULATE_LR[0][6],CALCULATE_LR[1][0],OFFSET[1]);    
    mux_1bit_2x1_module LRlayer21(CALCULATE_LR[0][1],CALCULATE_LR[0][7],CALCULATE_LR[1][1],OFFSET[1]);
    mux_1bit_2x1_module LRlayer22(CALCULATE_LR[0][2],CALCULATE_LR[0][0],CALCULATE_LR[1][2],OFFSET[1]);
    mux_1bit_2x1_module LRlayer23(CALCULATE_LR[0][3],CALCULATE_LR[0][1],CALCULATE_LR[1][3],OFFSET[1]);
    mux_1bit_2x1_module LRlayer24(CALCULATE_LR[0][4],CALCULATE_LR[0][2],CALCULATE_LR[1][4],OFFSET[1]);
    mux_1bit_2x1_module LRlayer25(CALCULATE_LR[0][5],CALCULATE_LR[0][3],CALCULATE_LR[1][5],OFFSET[1]);
    mux_1bit_2x1_module LRlayer26(CALCULATE_LR[0][6],CALCULATE_LR[0][4],CALCULATE_LR[1][6],OFFSET[1]);
    mux_1bit_2x1_module LRlayer27(CALCULATE_LR[0][7],CALCULATE_LR[0][5],CALCULATE_LR[1][7],OFFSET[1]);

    // MUX Layer 3
    mux_1bit_2x1_module LRlayer30(CALCULATE_LR[1][0],CALCULATE_LR[1][4],CALCULATE_LR[2][0],OFFSET[2]);    
    mux_1bit_2x1_module LRlayer31(CALCULATE_LR[1][1],CALCULATE_LR[1][5],CALCULATE_LR[2][1],OFFSET[2]);
    mux_1bit_2x1_module LRlayer32(CALCULATE_LR[1][2],CALCULATE_LR[1][6],CALCULATE_LR[2][2],OFFSET[2]);
    mux_1bit_2x1_module LRlayer33(CALCULATE_LR[1][3],CALCULATE_LR[1][7],CALCULATE_LR[2][3],OFFSET[2]);
    mux_1bit_2x1_module LRlayer34(CALCULATE_LR[1][4],CALCULATE_LR[1][0],CALCULATE_LR[2][4],OFFSET[2]);
    mux_1bit_2x1_module LRlayer35(CALCULATE_LR[1][5],CALCULATE_LR[1][1],CALCULATE_LR[2][5],OFFSET[2]);
    mux_1bit_2x1_module LRlayer36(CALCULATE_LR[1][6],CALCULATE_LR[1][2],CALCULATE_LR[2][6],OFFSET[2]);
    mux_1bit_2x1_module LRlayer37(CALCULATE_LR[1][7],CALCULATE_LR[1][3],CALCULATE_LR[2][7],OFFSET[2]);



    // right shift calculations
    // MUX Layer 1
    mux_1bit_2x1_module RRlayer10(DATA[7],DATA[0],CALCULATE_RR[0][7],OFFSET[0]);
    mux_1bit_2x1_module RRlayer11(DATA[6],DATA[7],CALCULATE_RR[0][6],OFFSET[0]);
    mux_1bit_2x1_module RRlayer12(DATA[5],DATA[6],CALCULATE_RR[0][5],OFFSET[0]);
    mux_1bit_2x1_module RRlayer13(DATA[4],DATA[5],CALCULATE_RR[0][4],OFFSET[0]);
    mux_1bit_2x1_module RRlayer14(DATA[3],DATA[4],CALCULATE_RR[0][3],OFFSET[0]);
    mux_1bit_2x1_module RRlayer15(DATA[2],DATA[3],CALCULATE_RR[0][2],OFFSET[0]);
    mux_1bit_2x1_module RRlayer16(DATA[1],DATA[2],CALCULATE_RR[0][1],OFFSET[0]);
    mux_1bit_2x1_module RRlayer17(DATA[0],DATA[1],CALCULATE_RR[0][0],OFFSET[0]);

    // MUX Layer 2
    mux_1bit_2x1_module RRlayer20(CALCULATE_RR[0][7],CALCULATE_RR[0][1],CALCULATE_RR[1][7],OFFSET[1]);    
    mux_1bit_2x1_module RRlayer21(CALCULATE_RR[0][6],CALCULATE_RR[0][0],CALCULATE_RR[1][6],OFFSET[1]);
    mux_1bit_2x1_module RRlayer22(CALCULATE_RR[0][5],CALCULATE_RR[0][7],CALCULATE_RR[1][5],OFFSET[1]);
    mux_1bit_2x1_module RRlayer23(CALCULATE_RR[0][4],CALCULATE_RR[0][6],CALCULATE_RR[1][4],OFFSET[1]);
    mux_1bit_2x1_module RRlayer24(CALCULATE_RR[0][3],CALCULATE_RR[0][5],CALCULATE_RR[1][3],OFFSET[1]);
    mux_1bit_2x1_module RRlayer25(CALCULATE_RR[0][2],CALCULATE_RR[0][4],CALCULATE_RR[1][2],OFFSET[1]);
    mux_1bit_2x1_module RRlayer26(CALCULATE_RR[0][1],CALCULATE_RR[0][3],CALCULATE_RR[1][1],OFFSET[1]);
    mux_1bit_2x1_module RRlayer27(CALCULATE_RR[0][0],CALCULATE_RR[0][2],CALCULATE_RR[1][0],OFFSET[1]);

    // MUX Layer 3
    mux_1bit_2x1_module RRlayer30(CALCULATE_RR[1][7],CALCULATE_RR[1][3],CALCULATE_RR[2][7],OFFSET[2]);    
    mux_1bit_2x1_module RRlayer31(CALCULATE_RR[1][6],CALCULATE_RR[1][2],CALCULATE_RR[2][6],OFFSET[2]);
    mux_1bit_2x1_module RRlayer32(CALCULATE_RR[1][5],CALCULATE_RR[1][1],CALCULATE_RR[2][5],OFFSET[2]);
    mux_1bit_2x1_module RRlayer33(CALCULATE_RR[1][4],CALCULATE_RR[1][0],CALCULATE_RR[2][4],OFFSET[2]);
    mux_1bit_2x1_module RRlayer34(CALCULATE_RR[1][3],CALCULATE_RR[1][7],CALCULATE_RR[2][3],OFFSET[2]);
    mux_1bit_2x1_module RRlayer35(CALCULATE_RR[1][2],CALCULATE_RR[1][6],CALCULATE_RR[2][2],OFFSET[2]);
    mux_1bit_2x1_module RRlayer36(CALCULATE_RR[1][1],CALCULATE_RR[1][5],CALCULATE_RR[2][1],OFFSET[2]);
    mux_1bit_2x1_module RRlayer37(CALCULATE_RR[1][0],CALCULATE_RR[1][4],CALCULATE_RR[2][0],OFFSET[2]);

    // setting the result
    always @(*) begin

        if (ROTATEAMOUNT[7]) begin // Right shift
            OFFSET = -ROTATEAMOUNT;
            RESULT = CALCULATE_RR[2];
        end
        else if (!ROTATEAMOUNT[7]) begin // Left shift
            OFFSET = ROTATEAMOUNT;
            RESULT = CALCULATE_LR[2];
        end

    end

endmodule


module alu (DATA1,DATA2,RESULT,SELECT,ZERO);
    input [`REG_SIZE-1:0] DATA1;
    input [`REG_SIZE-1:0] DATA2;
    output reg [`REG_SIZE-1:0] RESULT; // if we want to use wire insted of reg , we woud have to use 'assign' to do that use internal_RESULT and assign to RESULT at the end
    input [`REG_ADDRESS_SIZE-1:0] SELECT;
    output reg ZERO;

    // making wires to have each module's answer.
    wire [`REG_SIZE-1:0] MOV_RESULT;     
    wire [`REG_SIZE-1:0] ADD_RESULT;
    wire [`REG_SIZE-1:0] AND_RESULT;
    wire [`REG_SIZE-1:0] OR_RESULT;
    wire [`REG_SIZE-1:0] MULT_RESULT;
    wire [`REG_SIZE-1:0] SL_RESULT; // shift locically (left or right)
    wire [`REG_SIZE-1:0] SA_RESULT; // shift arithmaticaly (left or right)
    wire [`REG_SIZE-1:0] RO_RESULT; // rotate (left or right)

    // making instences for each module with seperated output 
    mov_module mov1(DATA2, MOV_RESULT);
    add_module add1(DATA1, DATA2, ADD_RESULT);
    and_module and1(DATA1, DATA2, AND_RESULT);
    or_module or1(DATA1, DATA2, OR_RESULT);
    mult_module mult1(DATA1, DATA2, MULT_RESULT);
    logical_shift_module sl1(DATA1, DATA2, SL_RESULT);
    arithmatic_shift_module sa1(DATA1, DATA2, SA_RESULT);
    rotate_module ro1(DATA1, DATA2, RO_RESULT);

    // to check of result is zero for the branch if equal command
    always @(*) begin
        if (!ADD_RESULT) begin
            ZERO = 1;
        end
        else begin
            ZERO = 0;
        end
    end

    // always block * to run the block whenever any input changes  
    always @(*)
    begin
        case (SELECT) //to SELECT what to output as a mux
        3'b000: // forward
            #1 RESULT = MOV_RESULT; 
        3'b001: // add or sub
            #2 RESULT = ADD_RESULT;
        3'b010: // and
            #1 RESULT = AND_RESULT;
        3'b011: // or
            #1 RESULT = OR_RESULT;
        3'b100: // mult
            #2 RESULT = MULT_RESULT;
        3'b101: // sl (logical shift)
            #2 RESULT = SL_RESULT;
        3'b110: // sa (arithmatic shift)
            #2 RESULT = SA_RESULT;
        3'b111: // ro (rotate)
            #2 RESULT = RO_RESULT;
        //default: 3'b1xx is reserved        
        
        endcase
    end 
endmodule