const RegisterLocations = enum { V0, V1, V2, V3, V4, V5, V6, V7, V8, V9, VA, VB, VC, VD, VE, VF };

const system_memory: [4096]u8 = undefined;

const address_register: u12 = 0;

const data_registers: [16]u8 = undefined;

const sound_timer: u32 = 0;
const delay_timer: u32 = 0;