
`include "cpu.v"

module cu_tb;
    reg [7:0] OPCODE;
    wire REG_DEST,MEM_READ,MEM_TO_REG,MEM_WRITE,ALU_SRC,REG_WRITE,TWOS_COMP;
    wire [2:0] ALU_OP;

    control_unit cu(OPCODE,ALU_OP,ALU_SRC,REG_WRITE,TWOS_COMP);

   initial
    begin
        # 2 // Latency for instruction register
        // Manually written
        OPCODE = 8'b00000000;
        #2
        OPCODE = 8'b00000001;
        #2
        OPCODE = 8'b00000010;
        #2
        OPCODE = 8'b00000011;
        #2
        OPCODE = 8'b00000100;
        #2
        OPCODE = 8'b00000101;
        
    end

    initial begin
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cu_wavedata.vcd");
		$dumpvars(0, cu_tb);
        // CLK = 1'b0;

        #20
        $finish;
    end
    
endmodule