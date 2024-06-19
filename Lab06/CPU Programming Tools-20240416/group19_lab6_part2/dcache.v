/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

module dcache (	
    clock,
    reset,
    cpu_read,
    cpu_write,
    cpu_address,
    cpu_writedata,
    cpu_readdata,
	cpu_busywait,
    mem_read,
    mem_write,
    mem_address,
    mem_writedata,
    mem_readdata,
	mem_busywait
    );

    input clock, reset;

    // CPU
    input cpu_read, cpu_write;
    input [7:0] cpu_address, cpu_writedata;
    output reg [7:0] cpu_readdata;
    output reg cpu_busywait;

    // Data Memory
    input [31:0] mem_readdata;
    input mem_busywait;
    output reg [31:0] mem_writedata;
    output reg [5:0] mem_address;
    output reg mem_read, mem_write;

    wire hit;                           // hit/miss signal
    wire [2:0] tag , index;             // tag(from cpu address) , index(from cpu address)
    wire [1:0] offset;                  // offset from the cpu address
    reg tagmatch;                       // reg for storing tag comparison result

    // Cache Data Structure
    reg [31:0] cacheblock_array [7:0];  // block array (32 bit * 8)
    reg dirty_array [7:0];              // dirty bit array (1 bit * 8) for each block
    reg valid_array [7:0];              // valid bit array (1 bit * 8) for each block
    reg [2:0] tagArray [7:0];           // tag array (3 bit * 8) for each block
    reg cache_write;                    // signal for write in cache


    // decording the address into tag, index, and offset.
    assign #1 tag = cpu_address[7:5];
    assign #1 index = cpu_address[4:2];
    assign #1 offset = cpu_address[1:0]; 

    // Set busywait bit to high if write or read signal given
    always @(cpu_read, cpu_write) begin
        cpu_busywait = (cpu_read || cpu_write) ? 1 : 0;
        if(cpu_write == 1)begin
            cache_write = 1;
        end
    end

    // Tag comparison and generate hit signal
    always @(*) begin
        #0.9
        if (tag == tagArray[index]) begin
            tagmatch = 1;
        end
        else begin
            tagmatch = 0;
        end
    end

    // Check if a hit or miss
    assign hit = tagmatch & valid_array[index];

    // If hit, handle read write de-assert busywait
    always @(posedge clock) begin
        if (hit) begin
            cpu_busywait = 0; // de-assert to prevent cpu stalking 
            if (cpu_read && !cpu_write) begin // If read
                cache_write = 0; // Stop writing if read signal
            end
            else if (cpu_write && !cpu_read) begin // If write
                cache_write = 1; // Allow writing if write signal
            end
        end
    end

    // Read words from cache
    always @(*) begin
        case (offset)
            // according to the offset give the relevant value from cache to CPU
            2'b00: cpu_readdata = #1 cacheblock_array[index][7:0];
            2'b01: cpu_readdata = #1 cacheblock_array[index][15:8];
            2'b10: cpu_readdata = #1 cacheblock_array[index][23:16];
            2'b11: cpu_readdata = #1 cacheblock_array[index][31:24];
        endcase
    end

    // Write to the cache at clock posedge 
    always @(posedge clock) begin
        if (cache_write && hit) begin
            case (offset)
                // according to the offset give the relevant value from CPU to cache
                2'b00: cacheblock_array[index][7:0] = #1 cpu_writedata;
                2'b01: cacheblock_array[index][15:8] = #1 cpu_writedata;
                2'b10: cacheblock_array[index][23:16] = #1 cpu_writedata;
                2'b11: cacheblock_array[index][31:24] = #1 cpu_writedata;
            endcase
            dirty_array[index] = 1; // mark the block as dirty
            cache_write = 0;
        end
    end

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010;
    reg [2:0] state, next_state;

    // Combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((cpu_read || cpu_write) && !dirty_array[index] && !hit) // need block replace but not dirty
                    next_state = MEM_READ;
                else if ((cpu_read || cpu_write) && dirty_array[index] && !hit) // need block replace but dirty
                    next_state = MEM_WRITE;
                else // Remain IDLE
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait) // Move to IDLE
                    next_state = IDLE;
                else // Remain MEM_READ if still busy
                    next_state = MEM_READ;
            
            MEM_WRITE:
                if (!mem_busywait)
                    next_state = MEM_READ; // Move to MEM_READ state after memory write completes
                else 
                    next_state = MEM_WRITE;
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE: // Stay IDLE
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 8'dx;
                mem_writedata = 8'dx;
                cpu_busywait = 0;
            end
         
            MEM_READ: // Read from the memory to cache
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index};
                mem_writedata = 32'dx;
                cpu_busywait = 1;

                #1 // After wait updating data
                if(mem_busywait == 0) begin
                    cacheblock_array[index] = mem_readdata; // Load data block from memory to cache
                    valid_array[index] = 1; // Mark the cache block as valid
                    tagArray[index] = tag; // Update the tag for the cache block
                end
            end
            
            MEM_WRITE: // Write to the memory from cache
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {tagArray[index], index};  
                mem_writedata = cacheblock_array[index]; // Write the cache block back to memory
                cpu_busywait = 1;

                if(mem_busywait == 0) begin
                    dirty_array[index] = 0; // Mark the cache block as not dirty
                end
            end
        endcase
    end

    integer i;
    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset) begin
            state = IDLE;
            for(i = 0 ; i < 7 ; i = i + 1) begin // Initialize all dirty bits to 0
                dirty_array[i] = 0 ;
                valid_array[i] = 0 ;
            end
        end
        else begin
            state = next_state;
        end
    end

    /* Cache Controller FSM End */

    // dump the values of the memory array to the gtkwave file
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

    initial
    begin
        $dumpfile("cpu_wavedata.vcd");
        for(i = 0;i<8;i++)
            $dumpvars(1,dirty_array[i]);
    end
endmodule