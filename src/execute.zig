const execution_context = @import("execution_context.zig");
const instructions = @import("instruction.zig");
const std = @import("std");

const lib = @import("lib.zig");

const dv = @import("dataview.zig");

const Instruction = instructions.Instruction;
const ExecutionContext = execution_context.ExecutionContext;

var rng = std.rand.DefaultPrng.init(0);

pub fn executeInstruction(ctx:*ExecutionContext, instruction:Instruction) void {
    const d1 = @bitCast(dv.D1, instruction.data);
    const d1_2 = @bitCast(dv.D1_2, instruction.data);
    const d1_3 = @bitCast(dv.D1_3, instruction.data);

    const reg = &ctx.data_registers;

    lib.jsLog(instruction.data);
    switch(instruction.opcode) {
        .@"0NNN" => {}, // Noop
        .@"00E0" => {
            var i:usize = 0;
            while(i < ctx.display.len) : (i+=1){
                ctx.display[i] = 0x00;
            }
        }, // Clear Display
        .@"00EE" => ctx.program_counter = ctx.stack.pop() - 2, // Returns from subroutine
        .@"1NNN" => ctx.program_counter = d1_3.b - 2,
        .@"2NNN" => { // Calls subroutine at NNN
            ctx.stack.push(ctx.program_counter);
            ctx.program_counter = d1_3.b - 2;
        },
        .@"3XNN" => { // Skips the next instruction if VX equals NN.
            if(reg[d1_2.b] == d1_2.c) ctx.program_counter += 2;
        },
        .@"4XNN" => { // Skips the next instruction if VX does not equal NN.

            if(reg[d1_2.b] != d1_2.c) ctx.program_counter += 2;
        },
        .@"5XY0" => { // Skips next instruction if registers are equal
            if(reg[d1.b] == reg[d1.c]) ctx.program_counter += 2;
        },
        .@"6XNN" => reg[d1_2.b] = d1_2.c, // Sets VX to NN
        .@"7XNN" => {
            reg[d1_2.b] = @truncate(u8, @intCast(u16, reg[d1_2.b]) + @intCast(u16, d1_2.c) & 0x00FF);
        }, // Adds NN to VX 
        .@"8XY0" => reg[d1.b] = reg[d1.c], // Sets VX to VY
        .@"8XY1" => reg[d1.b] |= reg[d1.c], // Sets VX to VX | VY
        .@"8XY2" => reg[d1.b] &= reg[d1.c], // Sets VX to VX & VY
        .@"8XY3" => reg[d1.b] ^= reg[d1.c], // Sets VX to VX ^ VY
        .@"8XY4" => {
            // Adds VY to VX with carry specified
            const res:u16 = reg[d1.b] + reg[d1.c];
            reg[0xF] = if(res > 255) 1 else 0; // Carry
            reg[d1.b] = @truncate(u8, res);
        },
        .@"8XY5" => {
            // subs VY to VX with carry specified
            reg[0xF] = if(reg[d1.b] > reg[d1.c]) 1 else 0; // Carry
            reg[d1.b] = reg[d1.b] - reg[d1.c];
        },
        .@"8XY6" => {
            // Divide by 2
            reg[0xF] = reg[d1.b] % 2; // Carry
            reg[d1.b] /= 2;
        },
        .@"8XY7" => {
            reg[0xF] = if(reg[d1.b] < reg[d1.b]) 1 else 0;
            reg[d1.b] = reg[d1.c] - reg[d1.b];
        },
        .@"8XYE" => {
            reg[0xF] = reg[d1.b] % 2; // Carry
            reg[d1.b] *= 2;
        },
        .@"9XY0" => {if(reg[d1.b] == reg[d1.c]) ctx.program_counter += 2;},
        .@"ANNN" => ctx.i = d1_3.b,
        .@"BNNN" => ctx.program_counter = ctx.i + reg[0x0] - 1, // Minus one because we always increment
        .@"CXNN" => reg[d1_2.b] = rng.random().int(u8) & d1_2.c, // Random
        .@"DXYN" => {
            lib.jsLog(ctx.i);

            const x = reg[d1.b];
            const y = reg[d1.c];

            for(ctx.system_memory[ctx.i..ctx.i+d1.d]) |byte, i| {
                const byte_index = ((i+y)*8) + (x / 8);
                var modified_bytes: []*u8 = undefined;
                const bit_offset:u3 = @intCast(u3, (x % 8));
                var byte_offset:i32 = 1;
                reg[0xF] = 0;

                if (byte_index != 0 and byte_index % 8 == 0){
                    byte_offset = -7;
                }

                if(bit_offset == 0) {
                    modified_bytes = &.{&ctx.display[byte_index]};
                } else {
                    lib.jsLog("HERE");
                    lib.jsLog(@intCast(i32, byte_index));
                    lib.jsLog(@intCast(i32, byte_offset + @intCast(i32, byte_index)));
                    lib.jsLog("HERE");
                    
                    modified_bytes = &.{
                        &ctx.display[byte_index], 
                        &ctx.display[@truncate(u8, @intCast(usize, byte_offset + @intCast(i32, byte_index)))]
                    };
                }


                for(modified_bytes) | ptr, j | {
                    if(j == 0) {
                        const old = ptr.*;
                        ptr.* ^= @bitReverse(u8, byte >> bit_offset);
                        if((ptr.* ^ old) & old != 0){
                            reg[0xF] = 1;
                        }

                    } else {

                        const old = ptr.*;
                        ptr.* ^= @bitReverse(u8, byte << (7 - (bit_offset-1)));
                        if((ptr.* ^ old) & old != 0){
                            reg[0xF] = 1;
                        }

                    }
                }
            }
        }, // Draw Sprite
        .@"EX9E" => {if(ctx.keyboard >> @truncate(u4, reg[d1.b]) & 1 == 1) ctx.program_counter += 2;}, // Keydown
        .@"EXA1" => {if(ctx.keyboard >> @truncate(u4, reg[d1.b]) & 1 != 1) ctx.program_counter += 2;}, // Not keydown
        .@"FX07" => reg[d1.b] = ctx.delay_timer,
        .@"FX0A" => {
            if(ctx.keyboard == 0) ctx.program_counter -= 2;
            var kbVal = ctx.keyboard;
            var j:u4 = 0;
            while(j < 16) : (j += 1) {
                if(kbVal >> j & 1 == 1) {
                    reg[d1.b] = j;
                }
            }
        }, // Wait for keypress then execute
        .@"FX15" => ctx.delay_timer = reg[d1.b],
        .@"FX18" => ctx.sound_timer = reg[d1.b],
        .@"FX1E" => ctx.i += reg[d1.b],
        .@"FX29" => {unreachable;}, // Sprite digit stuff
        .@"FX33" => {unreachable;}, // Store Decimal Representation in memory
        .@"FX55" => {
            var i:u8 = 0;
            while(i <= d1.b):(i+=1) {
                ctx.system_memory[ctx.i + i] = reg[i];
            }
        }, 
        .@"FX65" => {
            var i:u8 = 0;
            while(i <= d1.b):(i+=1) {
                reg[i] = ctx.system_memory[ctx.i + i];
            }
        },
    }
    ctx.program_counter += 2;
}