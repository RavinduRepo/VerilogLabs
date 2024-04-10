module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);
    input [7:0] IN;
    input [2:0] OUT1ADDRESS, OUT2ADDRESS, INADDRESS;
    output [7:0] OUT1, OUT2;
    input WRITE, CLK, RESET;

    // Internal register array
    reg [7:0] registers[7:0];

    // Output register (registers required since we cant assign if not registers)
    reg [7:0] out1_reg;
    reg [7:0] out2_reg;

    // Assign outputs to internal latches
    assign OUT1 = out1_reg;         
    assign OUT2 = out2_reg;
    
    always @(posedge CLK)
    begin
        if (RESET) // If reset is high
        begin
            // Reset all registers to 0 with time delay of #1
            registers[0] <= #1 8'b0;
            registers[1] <= #1 8'b0;
            registers[2] <= #1 8'b0;
            registers[3] <= #1 8'b0;
            registers[4] <= #1 8'b0;
            registers[5] <= #1 8'b0;
            registers[6] <= #1 8'b0;
            registers[7] <= #1 8'b0;
        end
        
        else if (WRITE) // If write is high
        begin
            registers[INADDRESS] <= #1 IN; // #1 propergation delay
        end
        
        else  // Else times output should be what ever address the pointers are pointing at
        begin   // Outputting values with #2 delay 
            out1_reg <= #2 registers[OUT1ADDRESS];      //here registers are reqired , since wirescant be used to store values
            out2_reg <= #2 registers[OUT2ADDRESS];
        end

    end

endmodule