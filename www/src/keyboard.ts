import { U8ArrayPointer } from "./pointers";

export default class Keyboard {
    public readonly elm = document.createElement('div');
    private keyStates:boolean[] = [];
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

        keyElm.onmousedown = () => this.setKey(i, true);            
        keyElm.onmouseleave = () => this.setKey(i, false);
        keyElm.onmouseup = () => this.setKey(i, false);

        this.elm.appendChild(keyElm);
    }

    private setKey(i:number, value:boolean) {
        const dv = new DataView(this.ptr.arr.buffer);
        let mask = 1 << i;

        if(value) {
            dv.setUint16(0, dv.getUint16(0) | mask);
        } else {
            dv.setUint16(0, dv.getUint16(0) & ~mask);
        }
    }

    public getKeyState(key:number):boolean {
        return Boolean(this.keyStates[key]);
    }

    public setKeyboardPtr(ptr: U8ArrayPointer) {
        this.ptr = ptr;
    }
}