const Opcode = @import("opcodes.zig").Opcode;
const dataview = @import("dataview.zig");

const Instruction = packed struct {
    opcode: Opcode,
    data: dataview.DV,
};
