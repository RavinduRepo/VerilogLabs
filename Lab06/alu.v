module mov_module (data2,result);
    input [7:0] data2;
    output [7:0] result;

    assign result = data2;

endmodule

module add_module (data1,data2,result);
    input [7:0] data1;
    input [7:0] data2;
    output reg [7:0] result;
    
    always @(*) 
    begin   // add - sub
    if (data2 < 0)  // or we can use (data2[7]) as the condition
        result = data1 - data2;
    else
        result = data1 + data2;
    end

endmodule

module and_module (data1,data2,result);
    input [7:0] data1;
    input [7:0] data2;
    output [7:0] result;

    assign result = data1 & data2;

endmodule

module or_module (data1,data2,result);
    input [7:0] data1;
    input [7:0] data2;
    output [7:0] result;

    assign result = data1 | data2;


endmodule

module alu (data1,data2,result,select);
    input [7:0] data1;
    input [7:0] data2;
    output reg [7:0] result; // if we want to use wire insted of reg , we woud have to use 'assign' to do that use internal_result and assign to result at the end
    input [2:0] select;

    // making wires to have each module's answer.
    wire [7:0] mov_result;     
    wire [7:0] add_result;
    wire [7:0] and_result;
    wire [7:0] or_result;

    // making instences for each module with seperated output 
    mov_module u0(data2, mov_result);
    add_module u1(data1, data2, add_result);
    and_module u3(data1, data2, and_result);
    or_module u4(data1, data2, or_result);

    // always block * to run the block whenever any input changes  
    always @(*)
    begin
        case (select) //to select what to output as a mux
        3'b000: // forward
            #1 result = mov_result; 
        3'b001: // add or sub
            #2 result = add_result;
        3'b010: // and
            #1 result = and_result;
        3'b011: // or
            #1 result = or_result;
        //default: 3'b1xx is reserved        
        
        endcase
    end 
endmodule