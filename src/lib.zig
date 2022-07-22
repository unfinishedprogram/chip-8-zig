const ec = @import("execution_context.zig");
const ExecutionContext = ec.ExecutionContext;
const std = @import("std");
const allocator = @import("allocator.zig").allocator;

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

export fn loadProgramRom(self: *ExecutionContext, program: [*]const u8, size:i32) void {
    ExecutionContext.loadProgramRom(self, program, size);
}

export fn step(self: *ExecutionContext) void {
    ExecutionContext.step(self);
}

export fn createExecutionContext() *ExecutionContext {
    const ctx = ec.createExecutionContext();
    return ctx;
}

export fn ping(num:i32) void {
    jslogNum(num);
}

pub export fn requestU8ArrBuffer(size:usize) usize {
    const ptr = allocator.alloc(u8, size) catch {
        jslog("err", 3);
        return 0x0;
    };

    return @ptrToInt(&ptr);
}

export fn getDisplayBuffer(self: *ExecutionContext) *[256]u8 {
    return &self.display;
}

export fn getKeyboardBuffer(self: *ExecutionContext) *[2]u8 {
    return &self.keyboard;
}