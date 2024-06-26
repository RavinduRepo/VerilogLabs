module icache (PC, INSTRUCTION, clock, reset, cpu_busywait, inst_busywait, read, readinst, address);
    input clock, reset;

    // CPU
    input [31:0] PC;
    output reg cpu_busywait;
    output reg [31:0] INSTRUCTION;

    // Instruction memory
    input [127:0] readinst; // block of instr_mem
    input inst_busywait; // 
    output reg [5:0] address;
    output reg read;

    wire hit;                          // hit/miss signal
    wire [2:0] tag, index;             // tag(from cpu address) , index(from cpu address)
    wire [3:0] offset;                 // offset from the cpu address
    reg tagmatch;                      // reg for storing tag comparison result

    // Cache Data Structure
    reg [127:0] cacheblock_array [7:0];  // block array (128 bit * 8)
    reg valid_array [7:0];              // valid bit array (1 bit * 8)
    reg [2:0] tagArray [7:0];           // tag array (3 bit * 8)

    // separating the address into tag, index, and offset
    assign #1 tag = PC[9:7];
    assign #1 index = PC[6:4];
    assign #1 offset = PC[3:0];

    // do the tag comparison and generate the hit signal using valid bit
    always @(index,tagArray[index],tag) begin
        #0.9
        if(tag == tagArray[index]) begin
            tagmatch = 1;
        end
        else begin
            tagmatch = 0;
        end
    end
    assign hit = tagmatch & valid_array[index];

    // Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    always @(*) begin
        if(hit) begin
            case(offset)
                4'b0000: INSTRUCTION = cacheblock_array[index][31:0];
                4'b0100: INSTRUCTION = cacheblock_array[index][63:32];
                4'b1000: INSTRUCTION = cacheblock_array[index][95:64];
                4'b1100: INSTRUCTION = cacheblock_array[index][127:96];
            endcase
        end
    end

    always @(*) begin
        if(hit) begin
          cpu_busywait = 0;
          //read = 0;
        end
        else begin
            cpu_busywait = 1;
            //read = 1;
        end
    end


    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001;
    reg [2:0] state, next_state;

    // Combinational next state logic
    always @(*) begin
        case (state)
            IDLE:
                if (!hit)  
                    next_state = MEM_READ; // Move to MEM_READ state if there's no hit
                else
                    next_state = IDLE; // Remain in IDLE state otherwise
            
            MEM_READ:
                if (!inst_busywait)
                    next_state = IDLE; // Move to IDLE state after memory read completes
                else    
                    next_state = MEM_READ; // Remain in MEM_READ state if memory is still busy
        endcase
    end

    // Combinational output logic
    always @(*) begin
        case(state)
            IDLE: begin
                read = 0;
                address = 10'dx;
                cpu_busywait = 0;
            end
         
            MEM_READ: begin
                read = 1;
                address = {tag, index};
                cpu_busywait = 1;

                #1 if(inst_busywait == 0) begin
                    cacheblock_array[index] = readinst; // Load data from memory to cache
                    valid_array[index] = 1; // Mark the cache block as valid
                    tagArray[index] = tag; // Update the tag for the cache block
                end
            end
        endcase
    end

    integer i;
    // Sequential logic for state transitioning and cache initialization
    always @(posedge clock, reset) begin
        if(reset) begin
            state = IDLE; // Initialize state to IDLE
            for(i = 0; i < 8; i = i + 1) begin
                valid_array[i] = 0; // Initialize all valid bits to 0
            end
        end else begin
            state = next_state; // Transition to next state
        end
    end

    //testing - dump the values of the memory array to the gtkwave file
    initial
    begin
        $dumpfile("cpu_wavedata.vcd");
        for(i = 0;i<8;i++)
            $dumpvars(1,cacheblock_array[i]);
    end

    initial
    begin
        $dumpfile("cpu_wavedata.vcd");
        for(i = 0;i<8;i++)
            $dumpvars(1,tagArray[i]);
    end

    initial
    begin
        $dumpfile("cpu_wavedata.vcd");
        for(i = 0;i<8;i++)
            $dumpvars(1,valid_array[i]);
    end

endmodule
