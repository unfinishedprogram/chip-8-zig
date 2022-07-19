const std = @import("std");
const print = std.debug.print;
const allocator = @import("allocator.zig").allocator;

const jslog = @import("lib.zig").jslog;
const jslogNum = @import("lib.zig").jslogNum;

const instructions = @import("instruction.zig");
const Instruction = instructions.Instruction;
const printInstruction = instructions.printInstruction;
const createInstruction = instructions.createInstruction;

const executeInstruction = @import("execute.zig").executeInstruction;
const expectEqual = std.testing.expectEqual;

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
    system_memory:[4096]u8 = undefined, // Program is loaded after the frist 512 bytes
    address_register: u12 = 0,
    data_registers: [16]u8 = undefined,
    sound_timer: u8 = 0,
    delay_timer: u8 = 0,
    program_counter: u16 = 0x200,
    stack:Stack = Stack{},
    i:u12 = 0,

    pub fn loadProgramRom(self: *ExecutionContext, program: [*]const u8, size:i32) void {
        jslogNum(@intCast(i32, @ptrToInt(program)));
        jslogNum(size);
        jslog("load rom", 8);

        var i:usize = 0;
        
        while(i < size): (i += 1) {
            jslogNum(@intCast(i32, i));
            self.system_memory[i + 0x200 ] = program[i];
        }

        jslog("done rom", 8);
    }
    
    pub fn step(self: *ExecutionContext) void {
        jslog("step", 4);
        // print("PC:{}\n", .{self.program_counter});

        const instruction = createInstruction(.{
            self.system_memory[self.program_counter], 
            self.system_memory[self.program_counter+1]
        });

        // try printInstruction(&instruction);
        executeInstruction(self, instruction);
    }
};

pub fn createExecutionContext() *ExecutionContext {
    jslog("make ctx", 8);

    const ptr = allocator.create(ExecutionContext) catch @panic("alloc err");
    ptr.* = ExecutionContext{};
    return ptr;
}

test "stack datastructure" {
    var myStack = Stack{};
    myStack.push(5);
    myStack.push(7);
    myStack.push(8);
    try expectEqual(@as(u12, 8), myStack.pop());
    try expectEqual(@as(u12, 7), myStack.pop());
    try expectEqual(@as(u12, 5), myStack.pop());
}