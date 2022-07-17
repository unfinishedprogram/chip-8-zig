const std = @import("std");
const Instruction = @import("instruction.zig").Instruction;
const executeInstruction = @import("execute.zig").executeInstruction;
const expectEqual = std.testing.expectEqual;

pub const Stack = struct {
    buffer:[48]u12 = undefined,
    counter: u16 = 0,

    pub fn pop(self:*Stack) u12 {
        self.counter -= 1;
        return self.buffer[self.counter];
    }

    pub fn push(self:*Stack, value:u12) void {
        self.buffer[self.counter] = value;
        self.counter+=1;
    }
};

pub const ExecutionContext = struct {
    system_memory: [4096]u8,
    adress_register: u12,
    data_registers: [16]u8,
    sound_timer: u32,
    delay_timer: u32,
    program_counter: u16,
    stack:Stack,
    i:u12,
    program: *[]Instruction,

    pub fn loadProgram(self:*ExecutionContext,program: *[]Instruction) !void {
        self.program = program;
    }

    pub fn step(self: *ExecutionContext) !void {
        executeInstruction(self, self.program[self.program_counter]);
        self.program_counter += 1;
    }
};

pub fn createExecutionContext() ExecutionContext {
    return ExecutionContext {
        .system_memory = undefined,
        .address_register = 0,
        .data_registers = undefined,
        .sound_timer = 0,
        .delay_timer = 0,
    };
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