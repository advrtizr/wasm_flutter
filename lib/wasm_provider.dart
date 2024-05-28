import 'package:flutter/services.dart';
import 'package:wasm_run_flutter/wasm_run_flutter.dart';

// Wasm provider.
class WasmProvider {
  late final WasmInstance _instance;

  WasmProvider();

  Future<WasmInstance> loadWasmFile() async {
    final wasmFile = await rootBundle.load('assets/wasm/tauon_test.wasm');
    final Uint8List binary = wasmFile.buffer.asUint8List();
    final WasmModule module = await compileWasmModule(
      binary,
      config: const ModuleConfig(
        wasmi: ModuleConfigWasmi(),
        wasmtime: ModuleConfigWasmtime(),
      ),
    );

    WasiConfig wasiConfig = const WasiConfig(
      env: [
        EnvVariable(name: 'wasi_snapshot_preview1', value: 'environ_get'),
      ],
      preopenedDirs: [],
      webBrowserFileSystem: {},
    );

    WasmInstanceBuilder builder = module.builder(wasiConfig: wasiConfig);
    _instance = await builder.build();
    return _instance;
  }

  // void getRandom() {
  //   int size = 32;
  //   final WasmFunction mymallocFunc = _instance.getFunction('mymalloc')!;
  //   final myMallocPtr = mymallocFunc.inner(size);

  //   final WasmFunction getRandomFunc = _instance.getFunction('getrandom')!;
  //   getRandomFunc.inner(myMallocPtr, size, 0);

  //   final wasmMemory = _instance.getMemory('memory');

  //   if (wasmMemory != null) {
  //     final data = wasmMemory.view.buffer.asUint8List(myMallocPtr, size);
  //     print('getRandom result: $data');
  //   }
  // }
}
