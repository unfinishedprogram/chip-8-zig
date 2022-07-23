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

pub extern fn jslogStr(message: [*]const u8, length: u8) void;
pub extern fn jslogNum(number:i32) void;

pub fn jsLog(value:anytype) void {
    switch (@typeInfo(@TypeOf(value))) {
        .Int => jslogNum(value),
        .Float => jslogNum(value),
        .Pointer => jslogStr(value, value.len),
        else => {
            const err_msg = "Type unsupported for printing";
            jslogStr(&err_msg, err_msg.len);
        }
        
    }
}


export fn loadProgramRom(self: *ExecutionContext, program: [*]const u8, size:i32) void {
    ExecutionContext.loadProgramRom(self, program, size);
}

export fn step(self: *ExecutionContext) void {
    ExecutionContext.step(self);
}

export fn createExecutionContext() *ExecutionContext {
    return ExecutionContext.create();
}

export fn ping(num:i32) void {
    jslogNum(num);
}

pub export fn requestU8ArrBuffer(size:usize) usize {
    const ptr = allocator.alloc(u8, size) catch {
        jsLog("err");
        return 0x0;
    };

    return @ptrToInt(&ptr);
}

export fn getDisplayBuffer(self: *ExecutionContext) *[256]u8 {
    return &self.display;
}

export fn getKeyboardBuffer(self: *ExecutionContext) *u16 {
    return &self.keyboard;
}