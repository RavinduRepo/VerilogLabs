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

module mult_module (DATA1,DATA2,RESULT);
    input [`REG_SIZE-1:0] DATA1;
    input [`REG_SIZE-1:0] DATA2;
    output [`REG_SIZE-1:0] RESULT;

    assign RESULT = DATA1 * DATA2;

endmodule

module logical_shift (DATA, SHIFTAMOUNT, RESULT);
    input [`REG_SIZE-1:0] DATA;
    input [`REG_SIZE-1:0] SHIFTAMOUNT;
    output reg [`REG_SIZE-1:0] RESULT;

    integer i;
    always @(*) begin
        if (!SHIFTAMOUNT[`REG_SIZE-1]) begin // left shift
            RESULT = DATA;
            for (i = 0; i < SHIFTAMOUNT; i = i + 1) begin
                RESULT = RESULT * 2;
            end
        end
        else if (SHIFTAMOUNT[`REG_SIZE-1]) begin // right shift
            RESULT = DATA;
            for (i = -0; i < SHIFTAMOUNT; i = i - 1) begin
                RESULT = RESULT / 2;
            end
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


    // making instences for each module with seperated output 
    mov_module mov1(DATA2, MOV_RESULT);
    add_module add1(DATA1, DATA2, ADD_RESULT);
    and_module and1(DATA1, DATA2, AND_RESULT);
    or_module or1(DATA1, DATA2, OR_RESULT);
    mult_module mult1(DATA1, DATA2, MULT_RESULT);
    logical_shift sl1(DATA1, DATA2, SL_RESULT);


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
        3'b101: // sll
            #2 RESULT = SL_RESULT;
        //default: 3'b1xx is reserved        
        
        endcase
    end 
endmodule