export interface WasmCtx {
    instance:WebAssembly.Instance,
    memory:WebAssembly.Memory;
    createExecutionContext:CallableFunction,
    loadProgramRom:CallableFunction,
    step:CallableFunction,
    ping:CallableFunction,
    requestU8ArrBuffer:CallableFunction,
}

export class WasmImport {
    public static async loadWasm(path:string, imports:WebAssembly.Imports):Promise<WasmCtx> {
        const data = await fetch(path);
        const buffer = await data.arrayBuffer();
        const results = await WebAssembly.instantiate(buffer, imports);
        const instance = results.instance;

        const step = instance.exports.step as CallableFunction;
        const createExecutionContext = instance.exports.createExecutionContext as CallableFunction;
        const loadProgramRom = instance.exports.loadProgramRom as CallableFunction;
        const ping = instance.exports.ping as CallableFunction;
        const requestU8ArrBuffer = instance.exports.requestU8ArrBuffer as CallableFunction;
        const memory = instance.exports.memory as WebAssembly.Memory;
        return {
            instance, 
            memory,
            step, 
            createExecutionContext, 
            loadProgramRom, 
            ping, 
            requestU8ArrBuffer
        };
    }
}