export default class Keyboard {
    public readonly elm = document.createElement('div');
    private keyStates:boolean[] = [];
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

        keyElm.onmousedown = () => this.keyStates[i] = true;            
        keyElm.onmouseleave = () => this.keyStates[i] = false;
        keyElm.onmouseup = () => this.keyStates[i] = false;

        this.elm.appendChild(keyElm);
    }

    public getKeyState(key:number):boolean {
        return Boolean(this.keyStates[key]);
    }
}