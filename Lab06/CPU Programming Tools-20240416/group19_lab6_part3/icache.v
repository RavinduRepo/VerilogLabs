module icache (
    input [31:0] PC,            // Program Counter from CPU
    output reg [31:0] INSTRUCTION, // Instruction output to CPU
    input clock,                // Clock signal
    input reset,                // Reset signal
    output reg cpu_busywait,    // CPU busywait signal
    input inst_busywait,        // Instruction memory busywait signal
    output reg read,            // Read signal for instruction memory
    input [127:0] readinst,     // Data read from instruction memory
    output reg [5:0] address    // Address output to instruction memory
);

    // Signals for cache hit/miss detection
    wire hit;
    wire [2:0] tag, index;
    wire [3:0] offset;
    reg tagmatch;

    // Cache data structure
    reg [127:0] cacheblock_array [7:0];  // 8 cache blocks, each 128 bits
    reg valid_array [7:0];               // Valid bits for each cache block
    reg [2:0] tagArray [7:0];            // Tag array for each cache block

    // Separate the address into tag, index, and offset
    assign #1 tag = PC[9:7];
    assign #1 index = PC[6:4];
    assign #1 offset = PC[3:0];

    // Tag comparison and hit signal generation
    always @(index, tagArray[index], tag) begin
        #0.9
        tagmatch = (tag == tagArray[index]) ? 1 : 0;
    end

    assign hit = tagmatch & valid_array[index];

    // Combinational logic for CPU instruction fetching
    always @(*) begin
        if (hit) begin
            case (offset)
                4'b0000: INSTRUCTION = cacheblock_array[index][31:0];
                4'b0100: INSTRUCTION = cacheblock_array[index][63:32];
                4'b1000: INSTRUCTION = cacheblock_array[index][95:64];
                4'b1100: INSTRUCTION = cacheblock_array[index][127:96];
            endcase
        end
    end

    // CPU busywait signal control
    always @(*) begin
        cpu_busywait = hit ? 0 : 1;
    end

    /* Cache Controller FSM Start */
    parameter IDLE = 3'b000, MEM_READ = 3'b001;
    reg [2:0] state, next_state;

    // Combinational next state logic
    always @(*) begin
        case (state)
            IDLE:
                next_state = hit ? IDLE : MEM_READ; // Transition to MEM_READ if no hit
            MEM_READ:
                next_state = inst_busywait ? MEM_READ : IDLE; // Stay in MEM_READ if memory is busy
        endcase
    end

    // Combinational output logic
    always @(*) begin
        case(state)
            IDLE: begin
                read = 0;
                address = 6'dx; // Don't care address
                cpu_busywait = 0;
            end
            MEM_READ: begin
                read = 1;
                address = {tag, index}; // Set address for memory read
                cpu_busywait = 1;
                #1 if (inst_busywait == 0) begin
                    cacheblock_array[index] = readinst; // Load data from memory to cache
                    valid_array[index] = 1; // Mark cache block as valid
                    tagArray[index] = tag; // Update cache block tag
                end
            end
        endcase
    end

    integer i;
    // Sequential logic for state transitioning and cache initialization
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state = IDLE; // Initialize state to IDLE
            for (i = 0; i < 8; i = i + 1) begin
                valid_array[i] = 0; // Initialize all valid bits to 0
            end
        end else begin
            state = next_state; // Transition to next state
        end
    end

    // Dump values of the memory array to the gtkwave file for testing
    initial begin
        $dumpfile("cpu_wavedata.vcd");
        for (i = 0; i < 8; i = i + 1) begin
            $dumpvars(1, cacheblock_array[i]);
            $dumpvars(1, tagArray[i]);
            $dumpvars(1, valid_array[i]);
        end
    end

endmodule
