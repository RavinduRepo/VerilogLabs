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
    output reg [`REG_SIZE-1:0] RESULT;

    integer i;
    always @(*) begin
        RESULT = DATA1;

        for (i = 1; i < DATA2; i = i + 1) begin
            RESULT = RESULT + DATA1;
        end
    end
    // assign RESULT = DATA1 * DATA2;

endmodule

module logical_shift_module (DATA, SHIFTAMOUNT, RESULT);
    input [`REG_SIZE-1:0] DATA;
    input [`REG_SIZE-1:0] SHIFTAMOUNT;
    output reg [`REG_SIZE-1:0] RESULT;

    integer j;
    always @(*) begin
        if (!SHIFTAMOUNT[`REG_SIZE-1]) begin // left shift
            for (j = `REG_SIZE-1; j >= 0 ; j = j - 1) begin
                RESULT[j] = DATA[j - 1];
                if (j == 0) begin
                    RESULT[j] = 1'b0;   
                end
            end
        end
        else if (SHIFTAMOUNT[`REG_SIZE-1]) begin // right shift
            for (j = 0; j < `REG_SIZE; j = j + 1) begin
                RESULT[j] = DATA[j + 1];
                if (j == `REG_SIZE-1) begin
                    RESULT[j] = 1'b0;   
                end
            end
        end
    end
endmodule

module arithmatic_shift_module (DATA, SHIFTAMOUNT, RESULT);
    input [`REG_SIZE-1:0] DATA;
    input [`REG_SIZE-1:0] SHIFTAMOUNT;
    output reg [`REG_SIZE-1:0] RESULT;

    integer j;
    always @(*) begin
        if (!SHIFTAMOUNT[`REG_SIZE-1]) begin // left shift
            for (j = `REG_SIZE-1; j >= 0 ; j = j - 1) begin
                RESULT[j] = DATA[j - 1];
                if (j == `REG_SIZE-1) begin
                    RESULT[j] = DATA[j];   
                end
                if (j == 0) begin
                    RESULT[j] = 1'b0;   
                end
            end 
        end
        else if (SHIFTAMOUNT[`REG_SIZE-1]) begin // right shift
            for (j = 0; j < `REG_SIZE; j = j + 1) begin
                RESULT[j] = DATA[j + 1];
                if (j == `REG_SIZE-1) begin
                    RESULT[j] = DATA[j];   
                end
            end          
        end
    end
endmodule

module rotate_module(DATA, ROTATEAMOUNT, RESULT);
    input [`REG_SIZE-1:0] DATA;
    input [`REG_SIZE-1:0] ROTATEAMOUNT;
    output reg [`REG_SIZE-1:0] RESULT;
    reg TEMPARY;

    integer j;
    always @(*) begin
        if (!ROTATEAMOUNT[`REG_SIZE-1]) begin // left rotate
            for (j = `REG_SIZE-1; j >= 0 ; j = j - 1) begin
                if (j == `REG_SIZE-1) begin
                    TEMPARY = DATA[j]; 
                    RESULT[j] = DATA[j - 1];
                end
                else if (j == 0) begin
                    RESULT[j] = TEMPARY;
                end
                else begin
                    RESULT[j] = DATA[j - 1];
                end
            end 
        end
        else if (ROTATEAMOUNT[`REG_SIZE-1]) begin // right rotate
            for (j = 0; j < `REG_SIZE; j = j + 1) begin
                if (j == 0) begin
                    TEMPARY = DATA[j]; 
                    RESULT[j] = DATA[j + 1];
                end
                else if (j == `REG_SIZE-1) begin
                    RESULT[j] = TEMPARY;
                end
                else begin
                    RESULT[j] = DATA[j + 1];
                end
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