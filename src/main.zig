const std = @import("std");
const rom_reader = @import("rom_reader.zig");

pub fn main() anyerror!void {
    const buffer = try rom_reader.getByteBufferFromFile("roms/pong.rom");
    
    const buffer_small = rom_reader.getOpCodes(buffer);

    rom_reader.printOpCodes(buffer_small);
    // std.debug.print("{s}\n", .{buffer_small});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
