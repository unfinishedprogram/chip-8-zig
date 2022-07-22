// Imported: JS -> WASM
// Exported: WASM -> JS

const decoder = new TextDecoder();

const DEFAULT_IMPORTS:ImportedFunctionFactories = {
    jslog: (ctx:WasmContext<any, any>) => function (str_ptr:number, size:number) {
        const buffer = new Uint8Array(ctx.memory!.buffer, str_ptr, size);
        const string = decoder.decode(buffer);
        console.log(string);
    },

    jslogNum: (ctx:WasmContext<any, any>) => function (num:number) {
        console.log(num);
    }
}

export type ImportedFunctionFactory<T extends Function> = (ctx:WasmContext<any, any>) => T;
export interface ImportedFunctionFactories extends Record<string, ImportedFunctionFactory<any>> {};

export type ExportedFunctionFactory<T extends Function> = (func:Function, ctx:WasmContext<any, any>) => T;
export interface ExportedFunctionFactories extends Record<string, ExportedFunctionFactory<any>> {};

export type FactoryResult<T extends ExportedFunctionFactories> = { [key in keyof T]: ReturnType<T[key]> };

export default class WasmContext<
    E extends ExportedFunctionFactories, 
    I extends ImportedFunctionFactories> {
    wasmLoaded:boolean = false;
    instance?:WebAssembly.Instance;
    module?:WebAssembly.Module;
    memory?:WebAssembly.Memory;
    functions?:FactoryResult<E>;

    constructor(
        private path:string, 
        private exportedFunctionFactories:E, 
        private importedFunctionFactories:I
    ) {
        Object.assign(importedFunctionFactories, DEFAULT_IMPORTS);
    }

    public async loadWasm () {
        const imports = this.createImportedFunctions();

        return new Promise((res, rej) =>
            fetch(this.path)
            .then(data => data.arrayBuffer())
            .then(buffer => WebAssembly.instantiate(buffer, { env:imports }))
            .then(results => res(this.handleWasmLoadResults(results)))
            .catch(() => rej())
        )
    }

    private createImportedFunctions() : WebAssembly.ModuleImports {
        const res:WebAssembly.ModuleImports = {};
        for(const key in this.importedFunctionFactories) {
            res[key] = this.importedFunctionFactories[key](this);
        }
        return res;
    }

    private handleWasmLoadResults(results:WebAssembly.WebAssemblyInstantiatedSource) {
        this.instance = results.instance;
        this.module = results.module;

        this.memory = this.instance.exports.memory as WebAssembly.Memory;

        this.handleWasmExportBinding();
        this.wasmLoaded = true;
        console.log(results);
    }

    private handleWasmExportBinding() {
        const exports = this.instance?.exports!;
        const unhandledKeys = new Set(Object.keys(this.exportedFunctionFactories));
        const exported:FactoryResult<E> = {} as FactoryResult<E>;
        const exportedFuncs = exports as Record<string, Function>;
        
        for(const key in exports){
            if(key == "memory") continue;
            if(!unhandledKeys.has(key)){
                console.warn(`Warning: ${key} is exported by wasm but not registered`)
            } else {
                exported[key as keyof E] = this.exportedFunctionFactories[key](exportedFuncs[key], this);
                unhandledKeys.delete(key);
            }
        }

        if(unhandledKeys.size > 0){
            unhandledKeys.forEach(key => 
                console.warn(`Warning: ${key} is registered but not exported by wasm`)
            )
        }

        this.functions = exported;
    }
}