const ec = @import("execution_context.zig");
const ExecutionContext = ec.ExecutionContext;
const std = @import("std");
const allocator = @import("allocator.zig").allocator;
const builtin = @import("builtin");
const opcodes = @import("opcodes.zig");

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
        .Int => jslogNum(@intCast(i32, value)),
        .Float => jslogNum(@floatToInt(i32, value)),
        .Pointer => jslogStr(value, value.len),
        else => {
            const err_msg = "Type unsupported for printing";
            jslogStr(err_msg, err_msg.len);
        }
    }
}

export fn loadProgramRom(self: *ExecutionContext, program: [*]const u8, size:usize) void {
    jsLog("Loading Program Rom");
    ExecutionContext.loadProgramRom(self, program, size);
}

export fn step(self: *ExecutionContext) void {
    ExecutionContext.step(self);
}

export fn createExecutionContext() *ExecutionContext {
    return ExecutionContext.create();
}

export fn ping(num:i32) void {
    jsLog(num);
}

pub export fn requestU8ArrBuffer(size:usize) usize {
    jsLog("Requesting U8 Arr buffer of size:");
    jsLog(size);

    const ptr = allocator.alloc(u8, size) catch {
        jsLog("err");
        return 0x0;
    };

    jsLog("Allocated");
    return @ptrToInt(&ptr);
}

export fn getDisplayBuffer(self: *ExecutionContext) *[256]u8 {
    jsLog("Get Display Buffer");
    return &self.display;
}

export fn getMemoryBuffer(self: *ExecutionContext) *[4096]u8 {
    jsLog("Get Memory Buffer");
    return &self.system_memory;
}

export fn getKeyboardBuffer(self: *ExecutionContext) *u16 {
    jsLog("Get Keyboard Buffer");
    return &self.keyboard;
}

export fn timerFire(self: *ExecutionContext) void {
    if(self.sound_timer >= 1) self.sound_timer -= 1;
    if(self.delay_timer >= 1) self.delay_timer -= 1;
}