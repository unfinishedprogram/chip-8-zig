import { U8ArrayPointer } from "./pointers";

export default class Keyboard {
    public readonly elm = document.createElement('div');
    private ptr:U8ArrayPointer;

    private static readonly keys = [
        '1', '2', '3', 'C',
        '4', '5', '6', 'D',
        '7', '8', '9', 'E',
        'A', '0', 'B', 'F'
    ]

    constructor() {
        this.elm.classList.add('keyboard');
        Keyboard.keys.forEach(this.addKey.bind(this));
    }

    private addKey(key:string, i:number) {
        const keyElm = document.createElement('button');

        keyElm.classList.add('key');
        keyElm.innerText = key;

        keyElm.onmousedown = () => this.setKey(parseInt(key, 16), true);            
        keyElm.onmouseleave = () => this.setKey(parseInt(key, 16), false);
        keyElm.onmouseup = () => this.setKey(parseInt(key, 16), false);

        this.elm.appendChild(keyElm);
    }

    private setKey(i:number, value:boolean) {
        const dv = new DataView(this.ptr.arr.buffer);
        let mask = Math.pow(2, i);
        if(value) {
            dv.setUint16(this.ptr.ptr, dv.getUint16(0, true) | mask, true);
        } else {
            dv.setUint16(this.ptr.ptr, dv.getUint16(0, true) & ~mask, true);
        }
    }

    public setKeyboardPtr(ptr: U8ArrayPointer) {
        this.ptr = ptr;
    }
}