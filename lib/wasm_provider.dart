import 'package:flutter/services.dart';
import 'package:wasm_run_flutter/wasm_run_flutter.dart';

// Wasm provider.
class WasmProvider {
  late final WasmInstance _instance;
  WasmInstance get instance => _instance;

  WasmProvider();

  Future<WasmInstance> createInstance(String path) async {
    final wasmFile = await rootBundle.load(path);
    final Uint8List binary = wasmFile.buffer.asUint8List();
    final WasmModule module = await compileWasmModule(
      binary,
      config: const ModuleConfig(
        wasmi: ModuleConfigWasmi(),
        wasmtime: ModuleConfigWasmtime(
          // staticMemoryMaximumSize: 1024 * 1024 * 1024,
          wasmMemory64: true,
          debugInfo: true,
          wasmMultiMemory: true,
          wasmBacktrace: true,
        ),
      ),
    );

    WasiConfig wasiConfig = const WasiConfig(
      env: [
        EnvVariable(name: 'wasi_snapshot_preview1', value: 'environ_get'),
      ],
      preopenedDirs: [],
      webBrowserFileSystem: {},
    );

    // final builder = module.builder(wasiConfig: wasiConfig);
    // WasmMemory _memory = builder.createMemory(minPages: 10, maxPages: 100);
    // _memory.grow(deltaPages);
    // _instance = await builder.build();

    _instance = await module.builder(wasiConfig: wasiConfig).build();
    return _instance;
  }
}
