import { U8ArrayPointer } from "./pointers";
import WasmContext from "./wasmContext";

const chip8WasmExports = {
    step: (step, ctx) => (ptr:number) => step(ptr),

    loadProgramRom:(loadProgramRom, ctx) => 
        (execution_ptr:number, arr_ptr:number, length:number) => 
            loadProgramRom(execution_ptr, arr_ptr, length),

    createExecutionContext: (createExecutionContext, ctx) => () => createExecutionContext() as number,

    ping: () => () => console.warn("UNIMPLEMENTED"),

    requestU8ArrBuffer:(requestU8ArrBuffer, ctx) => (size:number) => {
        return new U8ArrayPointer(ctx, requestU8ArrBuffer(size), size);
    },

    getDisplayBuffer:(getDisplayBuffer, ctx:WasmContext<any, any>) => (execution_ptr:number) => {
        return new U8ArrayPointer(ctx, getDisplayBuffer(execution_ptr), 256);
    },
    
    getKeyboardBuffer:(getKeyboardBuffer, ctx:WasmContext<any, any>) => (execution_ptr:number) => {
        return new U8ArrayPointer(ctx, getKeyboardBuffer(execution_ptr), 2);
    },

    getMemoryBuffer:(getMemoryBuffer, ctx:WasmContext<any, any>) => (execution_ptr:number) => {
        return new U8ArrayPointer(ctx, getMemoryBuffer(execution_ptr), 4096);
    },
    timerFire:(timerFire, ctx:WasmContext<any, any>) => (execution_ptr:number) => {
        timerFire(execution_ptr);
    }
}

export type Chip8Instance = Required<WasmContext<typeof chip8WasmExports, {}>>;

const chip8 = new Promise<Chip8Instance>((res, rej) => {
    const ctx = new WasmContext("build/chip-8.wasm", chip8WasmExports, {});
    console.log(ctx);
    ctx.loadWasm().then(() => res(ctx as Chip8Instance));
})

export default chip8;