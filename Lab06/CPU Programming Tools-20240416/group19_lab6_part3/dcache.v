/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description:
This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

module dcache (    
    input clock,
    input reset,
    input cpu_read,
    input cpu_write,
    input [7:0] cpu_address,
    input [7:0] cpu_writedata,
    output reg [7:0] cpu_readdata,
    output reg cpu_busywait,
    output reg mem_read,
    output reg mem_write,
    output reg [5:0] mem_address,
    output reg [31:0] mem_writedata,
    input [31:0] mem_readdata,
    input mem_busywait
);

    // Internal signals for cache
    wire hit;
    wire [2:0] tag, index;
    wire [1:0] offset;
    reg tagmatch;

    // Cache Data Structure
    reg [31:0] cacheblock_array [7:0]; // Cache blocks (32 bits * 8)
    reg dirty_array [7:0];             // Dirty bit array (1 bit * 8)
    reg valid_array [7:0];             // Valid bit array (1 bit * 8)
    reg [2:0] tagArray [7:0];          // Tag array (3 bits * 8)
    reg cache_write;                   // Cache write enable signal

    // Decoding the address into tag, index, and offset
    assign #1 tag = cpu_address[7:5];
    assign #1 index = cpu_address[4:2];
    assign #1 offset = cpu_address[1:0];

    // Set busywait signal when CPU read or write signal is given
    always @(*) begin
        cpu_busywait = (cpu_read || cpu_write) ? 1 : 0;
        if(cpu_write) begin
            cache_write = 1;
        end
    end

    // Tag comparison and generate hit signal
    always @(*) begin
        #0.9
        tagmatch = (tag == tagArray[index]) ? 1 : 0;
    end

    assign hit = tagmatch && valid_array[index];

    // Handle read/write on hit and de-assert busywait
    always @(posedge clock) begin
        if (hit) begin
            cpu_busywait = 0; // De-assert busywait to prevent CPU stalling
            if (cpu_read && !cpu_write) begin
                cache_write = 0; // Stop writing if read signal
            end else if (cpu_write && !cpu_read) begin
                cache_write = 1; // Allow writing if write signal
            end
        end
    end

    // Read data from cache based on offset
    always @(*) begin
        case (offset)
            2'b00: cpu_readdata = #1 cacheblock_array[index][7:0];
            2'b01: cpu_readdata = #1 cacheblock_array[index][15:8];
            2'b10: cpu_readdata = #1 cacheblock_array[index][23:16];
            2'b11: cpu_readdata = #1 cacheblock_array[index][31:24];
        endcase
    end

    // Write data to cache based on offset
    always @(posedge clock) begin
        if (cache_write && hit) begin
            case (offset)
                2'b00: cacheblock_array[index][7:0] = #1 cpu_writedata;
                2'b01: cacheblock_array[index][15:8] = #1 cpu_writedata;
                2'b10: cacheblock_array[index][23:16] = #1 cpu_writedata;
                2'b11: cacheblock_array[index][31:24] = #1 cpu_writedata;
            endcase
            dirty_array[index] = 1; // Mark the block as dirty
            cache_write = 0;
        end
    end

    /* Cache Controller FSM Start */
    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010;
    reg [2:0] state, next_state;

    // Combinational next state logic
    always @(*) begin
        case (state)
            IDLE:
                if ((cpu_read || cpu_write) && !dirty_array[index] && !hit)
                    next_state = MEM_READ; // Need block replacement but not dirty
                else if ((cpu_read || cpu_write) && dirty_array[index] && !hit)
                    next_state = MEM_WRITE; // Need block replacement and dirty
                else
                    next_state = IDLE; // Remain in IDLE
            
            MEM_READ:
                next_state = mem_busywait ? MEM_READ : IDLE; // Stay in MEM_READ if busy
            
            MEM_WRITE:
                next_state = mem_busywait ? MEM_WRITE : MEM_READ; // Move to MEM_READ after memory write completes
        endcase
    end

    // Combinational output logic
    always @(*) begin
        case(state)
            IDLE: begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx; // Don't care address
                mem_writedata = 32'dx; // Don't care data
                cpu_busywait = 0;
            end
         
            MEM_READ: begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index};
                mem_writedata = 32'dx;
                cpu_busywait = 1;

                #1 if(!mem_busywait) begin
                    cacheblock_array[index] = mem_readdata; // Load data from memory to cache
                    valid_array[index] = 1; // Mark the cache block as valid
                    tagArray[index] = tag; // Update the tag for the cache block
                end
            end
            
            MEM_WRITE: begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {tagArray[index], index};
                mem_writedata = cacheblock_array[index]; // Write the cache block back to memory
                cpu_busywait = 1;

                if(!mem_busywait) begin
                    dirty_array[index] = 0; // Mark the cache block as not dirty
                end
            end
        endcase
    end

    integer i;
    // Sequential logic for state transitioning and cache initialization
    always @(posedge clock or posedge reset) begin
        if(reset) begin
            state = IDLE;
            for(i = 0; i < 8; i = i + 1) begin
                dirty_array[i] = 0; // Initialize all dirty bits to 0
                valid_array[i] = 0; // Initialize all valid bits to 0
            end
        end else begin
            state = next_state; // Transition to next state
        end
    end

    /* Cache Controller FSM End */

    // Dump values of the memory array to the gtkwave file for testing
    initial begin
        $dumpfile("cpu_wavedata.vcd");
        for(i = 0; i < 8; i = i + 1) begin
            $dumpvars(1, cacheblock_array[i]);
            $dumpvars(1, tagArray[i]);
            $dumpvars(1, valid_array[i]);
            $dumpvars(1, dirty_array[i]);
        end
    end

endmodule
