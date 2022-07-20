type Pointer = number;

export interface WasmCtx {
    instance:WebAssembly.Instance,
    memory:WebAssembly.Memory;

    createExecutionContext: () => Pointer,
    loadProgramRom: (executionContext:Pointer, arrPtr: Pointer, size:number) => void,
    step: (executionContext:Pointer) => void,
    ping: (num:number) => void,
    requestU8ArrBuffer:(size:number) => Pointer,
    getDisplayBuffer:(executionContext:Pointer) => Pointer,
}

export class WasmImport {
    public static async loadWasm(path:string, imports:WebAssembly.Imports):Promise<WasmCtx> {
        const data = await fetch(path);
        const buffer = await data.arrayBuffer();
        const results = await WebAssembly.instantiate(buffer, imports);
        const instance = results.instance;
        const memory = instance.exports.memory as WebAssembly.Memory;
        return Object.assign({ instance, memory}, instance.exports) as any as WasmCtx;
    }
}