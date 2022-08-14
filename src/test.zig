const std = @import("std");

const ExecutionContext = @import("execution_context.zig").ExecutionContext;
const executeInstruction = @import("execute.zig").executeInstruction;
const createInstruction = @import("instruction.zig").createInstruction;

fn runRawInstruction(ctx:*ExecutionContext, raw:u16) void {
    const bytes:[2]u8 = .{@truncate(u8, raw), @truncate(u8, raw << 8)};
    const instruction = createInstruction(bytes);
    executeInstruction(ctx, instruction);
}

var rng = std.rand.DefaultPrng.init(0);

test "Opcode: 0NNN" {
    const ctx = ExecutionContext.create();
    runRawInstruction(ctx, 0x0000);
    var i:usize  = 0;
    while (i < 100) : (i+=1) {
        runRawInstruction(ctx, rng.random().int(u16) & 0x0FFF);
    }
}

