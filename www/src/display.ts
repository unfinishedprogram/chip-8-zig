import { U8ArrayPointer } from "./pointers";
let c = 0xFF

export default class Display {
    public canvas:HTMLCanvasElement = document.createElement("canvas");
    private ctx:CanvasRenderingContext2D;
    private buffer?:U8ArrayPointer;
    private img:ImageData;
    private dv:DataView;
    constructor() {
        this.canvas.width = 64;
        this.canvas.height = 32;
        this.ctx = this.canvas.getContext("2d")!;
        this.img = this.ctx.createImageData(64, 32);
        this.dv = new DataView(this.img.data.buffer);
    }

    setBuffer(buffer:U8ArrayPointer) {
        this.buffer = buffer;
        this.buffer.arr.fill(0);
    }

    update() {
        const arr = this.buffer?.arr!;
        for(let i = 0; i < arr.length; i++){
            const imgIndex = i * 8;
            const bits = arr[i].toString(2).padStart(8, "0").split("");
            for(let j = 0; j < 8; j++){
                const black = bits.pop() == "1" ? 0 : c;
                this.img.data[(imgIndex + j) * 4 + 3] = black;
            }
            //c = c == 0xFF ? 0xAA : 0xFF;
        }
        this.ctx.putImageData(this.img, 0, 0);
    }

}