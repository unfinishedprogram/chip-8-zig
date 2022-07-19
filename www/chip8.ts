import {WasmImport, WasmCtx} from "./wasmImport"

let ctx:WasmCtx;

function jslog(location : number, size : number) {
    const buffer = new Uint8Array((ctx.instance.exports.memory as WebAssembly.Memory).buffer, location, size);
    const decoder = new TextDecoder();
    const string = decoder.decode(buffer);
    console.log(string);
}

const jslogNum = console.log;

function initRomPicker(execution_ptr:number) {
    const elm = document.querySelector("#rom_picker") as HTMLInputElement;
    const reader = new FileReader();
    console.log(execution_ptr);

    elm.onchange = (e) => {
        const file = elm.files?.item(0)!;
        reader.onload = () => {
            // console.log(reader.result);
            const byteArray = new Uint8Array(reader.result as ArrayBuffer);
            const memory = ctx.instance.exports.memory;
            // console.log(byteArray.length)
            const arr = new Uint8Array(memory as any as ArrayBufferLike);
            const ptr = ctx.requestU8ArrBuffer(byteArray.length);
            console.log(ptr);
            
            const wasmArr = new Uint8Array(ctx.memory.buffer, ptr, byteArray.length);
            wasmArr.set(byteArray);
            ctx.loadProgramRom(execution_ptr, ptr, byteArray.length);
            for(let i = 0; i < 500; i++){
                ctx.step();
            }
        }
        reader.readAsArrayBuffer(file);
    }
}

WasmImport.loadWasm("build/chip-8.wasm", {env: {jslog, jslogNum}}).then(_ctx => {
    ctx = _ctx;
    console.log("Loaded")
    console.log(ctx);
    const execution_ptr = ctx.createExecutionContext();
    initRomPicker(execution_ptr);
});