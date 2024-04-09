module alu (data1,data2,result,select);
    input [7:0] data1;
    input [7:0] data2;
    output reg [7:0] result; // if we want to use wire insted of reg , we woud have to use 'assign' to do that use internal_result and assign to result at the end
    input [2:0] select;

    //always block * to run the block whenever any input changes  
    always @(*)
    begin
        case (select) //to select what to output as a mux
        3'b000: // forward
            #1 mov mov(data2,result); 
        3'b001: begin // add - sub
            if (data2 < 0)  // or we can use (data2[7]) as the condition
                #2 sub sub(data1,data2,result);
            else
                #2 add add(data1,data2,result);
            end

        3'b010: // and
            #1 and and(data1,data2,result);
        3'b011: // or
            #1 or or(data1,data2,result);
        // default: 3'b1xx is reserved        
        
        endcase
    end 
endmodule

module mov (data2,result);
    input [7:0] data2;
    output reg [7:0] result;

    assign result = data2;

endmodule

module add (data1,data2,result);
    input [7:0] data1;
    input [7:0] data2;
    output reg [7:0] result;

    assign result = data1 + data2;

endmodule

module sub (data1,data2,result);
    input [7:0] data1;
    input [7:0] data2;
    output reg [7:0] result;

    assign result = data1 - data2;

endmodule

module and (data1,data2,result);
    input [7:0] data1;
    input [7:0] data2;
    output reg [7:0] result;

    assign result = data1 & data2;

endmodule

module or (data1,data2,result);
    input [7:0] data1;
    input [7:0] data2;
    output reg [7:0] result;

    assign result = data1 | data2;

endmodule
