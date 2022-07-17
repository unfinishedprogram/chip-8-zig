const std = @import("std");

const expectEqual = std.testing.expectEqual;

const Opcode = enum {
    @"0NNN", @"00E0", @"00EE", @"1NNN",
    @"2NNN", @"3XNN", @"4XNN", @"5XY0",
    @"6XNN", @"7XNN", @"8XY0", @"8XY1",
    @"8XY2", @"8XY3", @"8XY4", @"8XY5",
    @"8XY6", @"8XY7", @"8XYE", @"9XY0",
    @"ANNN", @"BNNN", @"CXNN", @"DXYN",
    @"EX9E", @"EXA1", @"FX07", @"FX0A", 
    @"FX15", @"FX18", @"FX1E", @"FX29", 
    @"FX33", @"FX55", @"FX65",
};

pub fn toU4Arr(value:u16) [4]u4 {
    return .{
        @truncate(u4, (value & 0xF000) >> 12),
        @truncate(u4, (value & 0x0F00) >> 8),
        @truncate(u4, (value & 0x00F0) >> 4),
        @truncate(u4, (value & 0x000F)),
    };
}

pub fn getOpcode(code:u16) Opcode {
    const bytes = toU4Arr(code);
    return switch (bytes[0]) {
        0x0 => switch(code) {
            0x00e0 => Opcode.@"00E0",
            0x00ee => Opcode.@"00EE",
            else => Opcode.@"0NNN"
        },
        0x1 => Opcode.@"1NNN",
        0x2 => Opcode.@"2NNN",
        0x3 => Opcode.@"3XNN",
        0x4 => Opcode.@"4XNN",
        0x5 => Opcode.@"5XY0",
        0x6 => Opcode.@"6XNN",
        0x7 => Opcode.@"7XNN",
        0x8 => switch(bytes[3]) {
            0x0 => Opcode.@"8XY0",
            0x1 => Opcode.@"8XY1",
            0x2 => Opcode.@"8XY2",
            0x3 => Opcode.@"8XY3",
            0x4 => Opcode.@"8XY4",
            0x5 => Opcode.@"8XY5",
            0x6 => Opcode.@"8XY6",
            0x7 => Opcode.@"8XY7",
            0xe=>Opcode.@"8XYE",
            else => unreachable,
        },
        0x9 => Opcode.@"9XY0",
        0xa => Opcode.@"ANNN",
        0xb => Opcode.@"BNNN",
        0xc => Opcode.@"CXNN",
        0xd => Opcode.@"DXYN",
        0xe => switch(bytes[3]) {
            0x1 => Opcode.@"EXA1",
            0xe => Opcode.@"EX9E",
            else => unreachable,
        },
        0xf => switch(bytes[2]) {
            0x0 => switch(bytes[3]) {
                0x7 => Opcode.@"FX07",
                0xa => Opcode.@"FX0A",
                else => unreachable,
            },
            0x1 => switch(bytes[3]) {
                0x5 => Opcode.@"FX15",
                0x8 => Opcode.@"FX18",
                0xe => Opcode.@"FX1E",
                else => unreachable,
            },
            0x2 => Opcode.@"FX29",
            0x3 => Opcode.@"FX33",
            0x5 => Opcode.@"FX55",
            0x6 => Opcode.@"FX65",
            else => unreachable,
        },
    };
}
