import chip8, { Chip8Instance } from "./chip8Instance";
import Display from "./display";

const display = new Display();
document.body.appendChild(display.canvas);

chip8.then(chip8 => {
    const execution_ptr = chip8.functions.createExecutionContext();
    const display_buffer = chip8.functions.getDisplayBuffer(execution_ptr)
    display.setBuffer(display_buffer);
    console.log(display_buffer)
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

            let i = 512;
            let int = 0;

            int = setInterval(() => {
                ctx.functions.step(execution_ptr);
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