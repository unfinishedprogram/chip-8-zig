import WasmContext from "./wasmContext";

export class U8ArrayPointer {
    constructor(private ctx:WasmContext<any, any>, public ptr:number, public size:number) {
    }

    public get arr() {
        return new Uint8Array(this.ctx.memory!.buffer, this.ptr, this.size);
    }

    public set arr(value:Uint8Array) {
        this.arr.set(value);
    }
}