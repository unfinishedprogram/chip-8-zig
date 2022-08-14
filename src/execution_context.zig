const std = @import("std");
const print = std.debug.print;
const allocator = @import("allocator.zig").allocator;

const lib = @import("lib.zig");
const requestU8ArrBuffer = lib.requestU8ArrBuffer;
const setDisplayBuffer = lib.setDisplayBuffer;

const instructions = @import("instruction.zig");
const Instruction = instructions.Instruction;
const printInstruction = instructions.printInstruction;
const createInstruction = instructions.createInstruction;

const executeInstruction = @import("execute.zig").executeInstruction;
const expectEqual = std.testing.expectEqual;

const font_set:[80]u8 = .{ 
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80  // F
};

pub const Stack = struct {
    buffer:[12] u16 = undefined,
    counter: u16 = 0,

    pub fn pop(self:*Stack) u16 {
        self.counter -= 1;
        return self.buffer[self.counter];
    }

    pub fn push(self:*Stack, value:u16) void {
        self.buffer[self.counter] = value;
        self.counter+=1;
    }
};

pub const ExecutionContext = struct {
    // last_60hz_cycle: u64 = 0,
    system_memory: [4096]u8 = undefined, // Program is loaded after the frist 512 bytes
    address_register: u12 = 0,
    data_registers: [16]u8 = undefined,
    display: [256]u8 = undefined,
    keyboard: u16 = 0,
    sound_timer: u8 = 0,
    delay_timer: u8 = 0,
    program_counter: u16 = 0x200,
    stack:Stack = Stack{},
    i:u12 = 0,

    pub fn loadProgramRom(self: *ExecutionContext, program: [*]const u8, size:usize) void {
        lib.jsLog("load rom");

        var i:usize = 0;
        
        while(i < size): (i += 1) {
            self.system_memory[i + 0x200 ] = program[i];
        }

        lib.jsLog("done rom");
    }

    pub fn setFontSet(self: *ExecutionContext) void {
        for(font_set) | value, i | {
            self.system_memory[0x050 + i] = value;
        }
    }
    
    pub fn step(self: *ExecutionContext) void {
        const instruction = createInstruction(.{
            self.system_memory[self.program_counter], 
            self.system_memory[self.program_counter+1]
        });

        executeInstruction(self, instruction);
    }

    pub fn create() *ExecutionContext {
        lib.jsLog("make ctx");
        const ptr = allocator.create(ExecutionContext) catch @panic("alloc err");
        ptr.* = ExecutionContext{};
        setFontSet(ptr);
        return ptr;
    }
};