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