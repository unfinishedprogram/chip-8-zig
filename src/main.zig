const std = @import("std");
const rom_reader = @import("rom_reader.zig");
const opcodes = @import("opcodes.zig");

pub fn main() anyerror!void {
    const buffer = try rom_reader.getByteBufferFromFile("roms/pong.rom");
    const buffer_small = rom_reader.getOpCodes(buffer);
    rom_reader.printOpCodes(buffer_small);
}