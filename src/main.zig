const std = @import("std");
const rom_reader = @import("rom_reader.zig");
const opcodes = @import("opcodes.zig");
const instruction = @import("instruction.zig");

pub fn main() anyerror!void {
    const file_data_buffer = try rom_reader.getByteBufferFromFile("roms/pong.rom");
    const raw_opcodes = rom_reader.rotateBufferBits(file_data_buffer);
    const instructions = try rom_reader.getInstructionBuffer(raw_opcodes);

    for (instructions) |inst| {
        try instruction.printInstruction(&inst);
    }

    // rom_reader.printOpCodes(buffer_small);
}
