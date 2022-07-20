const std = @import("std");
const opcodes = @import("opcodes.zig");
const dataview = @import("dataview.zig");
const jslogNum = @import("lib.zig").jslogNum;

const Opcode = opcodes.Opcode;
const print = std.debug.print;

pub const Instruction = struct {
    opcode: Opcode,
    data: u16,
};

pub fn printInstruction(instruction: *const Instruction) !void {
    const d = @bitCast(dataview.D1, instruction.data);
    print("OP: {s}\n", .{@tagName(instruction.opcode)});
    print("DT: {X}{X}{X}{X}\n\n", .{d.a, d.b, d.c, d.d});
}

pub fn createInstruction(bytes: [2]u8) Instruction {
    const raw_opcode:u16 = std.math.rotl(u16, @bitCast([1]u16, bytes)[0], 8);
    return Instruction{
        .opcode = opcodes.getOpcode(raw_opcode),
        .data = raw_opcode,
    };
}
