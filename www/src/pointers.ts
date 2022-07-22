import WasmContext from "./wasmContext";

export class U8ArrayPointer {
    private _arr = new Uint8Array();
    public get arr() {
        this._arr = new Uint8Array(this.ctx.memory!.buffer, this.ptr, this.size);
        return this._arr;
    }
    constructor(private ctx:WasmContext<any, any>, public ptr:number, public size:number) {
        this._arr = new Uint8Array(this.ctx.memory!.buffer, this.ptr, this.size);
    }
}