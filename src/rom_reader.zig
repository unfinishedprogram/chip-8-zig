const std = @import("std");
const opcodes = @import("opcodes.zig");
const dataview = @import("dataview.zig");
const instruction = @import("instruction.zig");
const allocator = @import("allocator.zig").allocator;

const Instruction = instruction.Instruction;
const io = std.io;
const read_only = std.fs.File.OpenMode.read_only;

pub fn getByteBufferFromFile(fileName: []const u8) !*[]const u8 {
    const file = try std.fs.cwd().openFile(fileName, .{ .mode = read_only });
    defer file.close();
    const reader = file.reader();
    var buffer: [4096]u8 = undefined;
    const size: usize = try reader.read(buffer[0..]);
    std.debug.print("Read:{} Bytes\n", .{size});
    return &buffer[0..size];
}

// Provides the strange bit positioning nececary
pub fn rotateBufferBits(buffer: []u8) []u16 {
    var res = @bitCast([]u16, buffer);
    res.len /= 2; // len / 2 since bytelength is double for each value;
    for (res) |val, i| {
        // Bitshifting magic
        res[i] = std.math.rotl(u16, val, 8);
    }
    return res;
}

pub fn getInstructionBuffer(raw_opcodes: []u16) ![]Instruction {
    const instructionBuffer:[]Instruction = try allocator.alloc(Instruction, raw_opcodes.len);
    errdefer allocator.free(instructionBuffer);
    for (raw_opcodes) |code, i| {
        instructionBuffer[i] = instruction.createInstruction(code);
    }
    return instructionBuffer;
}