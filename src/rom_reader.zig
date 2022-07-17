const std = @import("std");
const opcodes = @import("opcodes.zig");
const io = std.io;
const read_only = std.fs.File.OpenMode.read_only;

pub fn getByteBufferFromFile(fileName: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(fileName, .{.mode = read_only});
    defer file.close();
    
    const reader = file.reader();
    var buffer: [4096]u8 = undefined;
    const size:usize = try reader.read(buffer[0..]);
    std.debug.print("Read:{} Bytes\n", .{size});
    return buffer[0..size];
}

pub fn getOpCodes(buffer:[]u8) []u16 {
    var res = @bitCast([]u16, buffer);
    res.len = buffer.len/2;
    for(res) |val, i| {
        res[i] = std.math.rotl(u16, val, 8);
    }
    return res;
}

pub fn printOpCodes(buffer:[]u16) void {
    for(buffer) |val, i| {
        if(i % 4 == 0) std.debug.print("\n", .{});
        std.debug.print("{X:0>4} ", .{(opcodes.getOpcode(val))});
    
    }
}