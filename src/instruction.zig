const std = @import("std");
const opcodes = @import("opcodes.zig");
const dataview = @import("dataview.zig");


const Opcode = opcodes.Opcode;
const print = std.debug.print;

pub const Instruction = struct {
    opcode: Opcode,
    data: u16,
};

pub fn printInstruction(instruction: *const Instruction) !void {
    print("{s}\n", .{@tagName(instruction.opcode)});
}

pub fn createInstruction(raw_opcode: u16) Instruction {
    return Instruction{
        .opcode = opcodes.getOpcode(raw_opcode),
        .data = raw_opcode,
    };
}
