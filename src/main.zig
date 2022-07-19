const std = @import("std");
const rom_reader = @import("rom_reader.zig");
const opcodes = @import("opcodes.zig");
const instruction = @import("instruction.zig");
const execution_context = @import("execution_context.zig");


pub fn main() anyerror!void {
    const file_data_buffer = try rom_reader.getByteBufferFromFile("roms/maze.rom");
    var context = execution_context.createExecutionContext();
    context.loadProgramRom(file_data_buffer, file_data_buffer.len);
    // var x:i32 = 100;

    // while(x > 0):(x-=1) {
    //     // execution_context.ExecutionContext.step(context);
    //     context.step();
    // }
}
