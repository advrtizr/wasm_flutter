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

    _instance = await module.builder(wasiConfig: wasiConfig).build();
    return _instance;
  }
}
