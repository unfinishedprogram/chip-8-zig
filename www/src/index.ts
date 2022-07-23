import chip8, { Chip8Instance } from "./chip8Instance";
import Display from "./display";
import Keyboard from "./keyboard";

const display = new Display();
document.body.appendChild(display.canvas);

const keyboard = new Keyboard();
document.body.appendChild(keyboard.elm);

chip8.then(chip8 => {
    const execution_ptr = chip8.functions.createExecutionContext();
    const display_buffer = chip8.functions.getDisplayBuffer(execution_ptr);
    const keyboard_buffer = chip8.functions.getKeyboardBuffer(execution_ptr);
    display.setBuffer(display_buffer);
    keyboard.setKeyboardPtr(keyboard_buffer);
    initRomPicker(chip8, execution_ptr);
})

function initRomPicker(ctx:Chip8Instance, execution_ptr:number) {
    const elm = document.querySelector("#rom_picker") as HTMLInputElement;
    const reader = new FileReader();

    elm.onchange = (e) => {
        const file = elm.files?.item(0)!;

        reader.onload = () => {
            const fileData = new Uint8Array(reader.result as ArrayBuffer);
            const buffer = ctx.functions.requestU8ArrBuffer(512);
            console.log(buffer);
            buffer.arr.set(fileData);

            ctx.functions.loadProgramRom(execution_ptr, buffer.ptr, buffer.size);

            let pc = 0;

            const step = () => {
                pc++;
                if(pc % 100 == 0){
                    console.log(pc);
                }
                ctx.functions.step(execution_ptr);
            }
            // document.addEventListener("keypress", () => {
            //     step();
            // })
            // const t = performance.now();
            // for(let i = 0; i < 100000; i++){
            //     step();
            // }
            // console.log("TIME:", performance.now()-t);
            setInterval(() => {
                step();
                display.update();
            }, 250)
        }
        reader.readAsArrayBuffer(file);
    }
}