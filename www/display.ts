export default class Display {
    public canvas:HTMLCanvasElement = document.createElement("canvas");
    private ctx:CanvasRenderingContext2D;
    private buffer:Uint8Array = new Uint8Array(256);
    private img:ImageData;
    private dv:DataView;
    constructor() {
        this.canvas.width = 64;
        this.canvas.height = 32;
        this.ctx = this.canvas.getContext("2d")!;
        this.img = this.ctx.createImageData(64, 32);
        this.dv = new DataView(this.img.data.buffer);
    }

    setBuffer(buffer:ArrayBuffer, ptr:number) {
        this.buffer = new Uint8Array(buffer, ptr, 256);
        this.buffer.fill(0);
        console.log("Display : ptr: ", ptr);
        console.log(this.buffer);
    }

    update() {
        for(let i = 0; i < this.buffer.length; i++){
            const imgIndex = i * 8;
            const bits = this.buffer[i].toString(2).padStart(8, "0").split("");
            for(let j = 0; j < 8; j++){
                const black = bits.pop() == "1" ? 0 : 255;
                this.img.data[(imgIndex + j) * 4 + 3] = black;
            }
        }
        this.ctx.putImageData(this.img, 0, 0);
    }

}