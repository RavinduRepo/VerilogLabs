`define REG_ADDRESS_SIZE 3 // Size of a register address
`define REG_SIZE 8 // size of a register

module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);
    input [`REG_SIZE-1:0] IN;
    input [`REG_ADDRESS_SIZE-1:0] OUT1ADDRESS, OUT2ADDRESS, INADDRESS;
    output [`REG_SIZE-1:0] OUT1, OUT2;
    input WRITE, CLK, RESET;

    // Internal register array
    reg [`REG_SIZE-1:0] registers[`REG_SIZE-1:0];

    // Assign outputs to internal latches
    assign #2 OUT1 = registers[OUT1ADDRESS];         
    assign #2 OUT2 = registers[OUT2ADDRESS];
    
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

    end

endmodule