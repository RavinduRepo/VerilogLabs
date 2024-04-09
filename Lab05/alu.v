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
            #1 result = data2; 
        3'b001: begin // add - sub
            if (data2 < 0)  // or we can use (data2[7]) as the condition
                #2 result = data1 - data2;
            else
                #2 result = data1 + data2;
            end

        3'b010: // and
            #1 result = data1 & data2;
        3'b011: // or
            #1 result = data1 | data2;
        // default: 3'b1xx is reserved        
        
        endcase
    end 

endmodule


