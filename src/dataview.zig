const std = @import("std");
const print = std.debug.print;

const opcodes = @import("opcodes.zig");
const Opcode = opcodes.Opcode;

pub const DN = packed struct { a: u16 };
pub const D1 = packed struct { d: u4, c: u4, b: u4, a: u4 };
pub const D2 = packed struct { b: u8, a: u8 };
pub const D1_3 = packed struct { b: u12, a: u4 };
pub const D1_2 = packed struct { c: u8, b: u4, a: u4 };

pub const DVTag = enum { d1, d2, d1_3, d1_2, dn };
pub const DV = union(DVTag) { d1: D1, d2: D2, d1_3: D1_3, d1_2: D1_2, dn: DN };

pub fn getOpcodeDataViewType(code: Opcode) type {
    _ = code;
    return D1;
    // return switch (code) {
    //     .@"0NNN" => D1_3,
    //     .@"00E0" => DN,
    //     .@"00EE" => DN,
    //     .@"1NNN" => D1_3,
    //     .@"2NNN" => D1_3,
    //     .@"3XNN" => D1_2,
    //     .@"4XNN" => D1_2,
    //     .@"5XY0" => D1,
    //     .@"6XNN" => D1_2,
    //     .@"7XNN" => D1_2,
    //     .@"8XY0" => D1,
    //     .@"8XY1" => D1,
    //     .@"8XY2" => D1,
    //     .@"8XY3" => D1,
    //     .@"8XY4" => D1,
    //     .@"8XY5" => D1,
    //     .@"8XY6" => D1,
    //     .@"8XY7" => D1,
    //     .@"8XYE" => D1,
    //     .@"9XY0" => D1,
    //     .@"ANNN" => D1_3,
    //     .@"BNNN" => D1_3,
    //     .@"CXNN" => D1_2,
    //     .@"DXYN" => D1,
    //     .@"EX9E" => D1,
    //     .@"EXA1" => D1,
    //     .@"FX07" => D1,
    //     .@"FX0A" => D1,
    //     .@"FX15" => D1,
    //     .@"FX18" => D1,
    //     .@"FX1E" => D1,
    //     .@"FX29" => D1,
    //     .@"FX33" => D1,
    //     .@"FX55" => D1,
    //     .@"FX65" => D1,
    // };
}
