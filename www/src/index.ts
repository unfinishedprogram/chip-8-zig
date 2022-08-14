import chip8, { Chip8Instance } from "./chip8Instance";
import Display from "./display";
import Keyboard from "./keyboard";
import { U8ArrayPointer } from "./pointers";

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

            console.log("FileSize", fileData.length);

            const buffer = ctx.functions.getMemoryBuffer(execution_ptr);
            const rom = new U8ArrayPointer(ctx as any, buffer.ptr+512, 4096-512);
            rom.arr.set(fileData);

            const step = () => {
                ctx.functions.step(execution_ptr);
            }
            
            const interval = setInterval(() => {
                step();
            }, 2)

            const timers = setInterval(() => {
                display.update();
                ctx.functions.timerFire(execution_ptr);
            }, 16)
        }
        reader.readAsArrayBuffer(file);
    }
}