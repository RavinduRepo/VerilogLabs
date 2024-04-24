`define REG_SIZE 8

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

module alu (DATA1,DATA2,RESULT,select);
    input [`REG_SIZE-1:0] DATA1;
    input [`REG_SIZE-1:0] DATA2;
    output reg [`REG_SIZE-1:0] RESULT; // if we want to use wire insted of reg , we woud have to use 'assign' to do that use internal_RESULT and assign to RESULT at the end
    input [`REG_SIZE-1:0] select;

    // making wires to have each module's answer.
    wire [`REG_SIZE-1:0] MOV_RESULT;     
    wire [`REG_SIZE-1:0] ADD_RESULT;
    wire [`REG_SIZE-1:0] AND_RESULT;
    wire [`REG_SIZE-1:0] OR_RESULT;

    // making instences for each module with seperated output 
    mov_module u0(DATA2, MOV_RESULT);
    add_module u1(DATA1, DATA2, ADD_RESULT);
    and_module u3(DATA1, DATA2, AND_RESULT);
    or_module u4(DATA1, DATA2, OR_RESULT);

    // always block * to run the block whenever any input changes  
    always @(*)
    begin
        case (select) //to select what to output as a mux
        3'b000: // forward
            #1 RESULT = MOV_RESULT; 
        3'b001: // add or sub
            #2 RESULT = ADD_RESULT;
        3'b010: // and
            #1 RESULT = AND_RESULT;
        3'b011: // or
            #1 RESULT = OR_RESULT;
        //default: 3'b1xx is reserved        
        
        endcase
    end 
endmodule