const ec = @import("execution_context.zig");
const ExecutionContext = ec.ExecutionContext;
const std = @import("std");
const allocator = @import("allocator.zig").allocator;


// TODO Write helper to send arrays between Wasm and JS
// Must work like networking, JS requests array, wasm sends buffer to populate

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    _ = level;
    _ = scope;
    _ = format;
    _ = args; 
}

pub extern fn jslog(message: [*]const u8, length: u8) void;
pub extern fn jslogNum(number:i32) void;

export fn loadProgramRom(self: *ExecutionContext, program: [*]const u8, num:i32) void {
    jslogNum(num);
    ExecutionContext.loadProgramRom(self, program, num);
}

export fn step(self: *ExecutionContext) void {
    ExecutionContext.step(self);
}

export fn createExecutionContext() *ExecutionContext {
    return ec.createExecutionContext();
}

export fn ping(num:i32) void {
    jslogNum(num);
}


export fn requestU8ArrBuffer(size:usize) usize {
    const ptr = allocator.alloc(u8, size) catch {
        jslog("err", 3);
        return 0x0;
    };
    return @ptrToInt(&ptr);
}
