const execution_context = @import("execution_context.zig");
const instructions = @import("instruction.zig");
const std = @import("std");

const dv = @import("dataview.zig");

const print = std.debug.print;
const Instruction = instructions.Instruction;
const ExecutionContext = execution_context.ExecutionContext;


pub fn executeInstruction(ctx:*ExecutionContext, instruction:Instruction) !void {
    print("Executing Instruction", .{});
    const d1 = @bitCast(dv.D1, instruction.data);
    // const d2 = @bitCast(dv.D2, instruction.data);
    const d1_2 = @bitCast(dv.D1_2, instruction.data);
    const d1_3 = @bitCast(dv.D1_3, instruction.data);


    const reg = ctx.data_registers;
    switch(instruction.opcode) {
        .@"0NNN" => {}, // Noop for now
        .@"00E0" => {}, // Clear Display
        .@"00EE" => ctx.program_counter = ctx.stack.pop() - 1, // Returns from subroutine
        .@"1NNN" => ctx.program_counter = d1_3.b - 1,
        .@"2NNN" => { // Calls subroutine at NNN
            ctx.stack.push(ctx.program_counter);
            ctx.program_counter = d1_3.b - 1;
        },
        .@"3XNN" => { // Skips the next instruction if VX equals NN.
            if(reg[d1_2.b] == d1_2.c) ctx.program_counter += 1;
        },
        .@"4XNN" => { // Skips the next instruction if VX does not equal NN.
            if(reg[d1_2.b] != d1_2.c) ctx.program_counter += 1;
        },
        .@"5XY0" => {
            if(reg[d1_2.b] == reg[d1_2.c]) ctx.program_counter += 1;
        },
        .@"6XNN" => reg[d1_2.b] = d1_2.c, // Sets VX to NN
        .@"7XNN" => reg[d1_2.b] += d1_2.c, // Adds NN to VX 
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
        .@"9XY0" => {if(reg[d1.b] == reg[d1.c]) ctx.program_counter += 1;},
        .@"ANNN" => ctx.i = reg[d1_3.b],
        .@"BNNN" => ctx.program_counter = ctx.i + reg[0x0] - 1, // Minus one because we always increment
        .@"CXNN" => {}, // Random
        .@"DXYN" => {}, // Draw Sprite
        .@"EX9E" => {}, // Keyboard
        .@"EXA1" => {}, // Keyboard
        .@"FX07" => reg[d1.b] = ctx.delay_timer,
        .@"FX0A" => {}, // Keyboard
        .@"FX15" => ctx.delay_timer = reg[d1.b],
        .@"FX18" => ctx.sound_timer = reg[d1.b],
        .@"FX1E" => ctx.i += reg[d1.b],
        .@"FX29" => {}, // Sprite digit stuff
        .@"FX33" => {}, // Store Decimal Representation in memory
        .@"FX55" => {
            var i = 0;
            while(i <= d1.b):(i+=1) {
                ctx.system_memory[ctx.i + i] = reg[i];
            }
        }, 
        .@"FX65" => {
            var i = 0;
            while(i <= d1.b):(i+=1) {
                reg[i] = ctx.system_memory[ctx.i + i];
            }
        },
    }
    ctx.program_counter += 1;
}