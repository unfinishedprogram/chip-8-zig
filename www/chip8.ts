import {WasmImport, WasmCtx} from "./wasmImport"
import Display from "./display";

let ctx:WasmCtx;

const display = new Display();
document.body.appendChild(display.canvas);

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

    elm.onchange = (e) => {
        const file = elm.files?.item(0)!;
        reader.onload = () => {
            const byteArray = new Uint8Array(reader.result as ArrayBuffer);

            const display_ptr:number = ctx.getDisplayBuffer(execution_ptr);
            const ptr:number = ctx.requestU8ArrBuffer(byteArray.length);

            const arr = new Uint8Array(ctx.memory.buffer, ptr, byteArray.length);

            arr.set(byteArray);
            ctx.loadProgramRom(execution_ptr, ptr, byteArray.length);

            display.setBuffer(ctx.memory.buffer, display_ptr);
            console.log("DisplayPtr:", display_ptr);
            let i = 512;
            let int = 0;
            int = setInterval(() => {
                ctx.step(execution_ptr);
                display.update();
                i--;
                if(i <= 0){
                    clearInterval(int);
                }
            }, 100)
        
        }

        reader.readAsArrayBuffer(file);
    }
}



WasmImport.loadWasm("build/chip-8.wasm", {env: {jslog, jslogNum}}).then(_ctx => {
    ctx = _ctx;
    console.log("Loaded")
    console.log(ctx);
    const execution_ptr = ctx.createExecutionContext();
    console.log("execution ptr: ", execution_ptr);
    initRomPicker(execution_ptr);
});