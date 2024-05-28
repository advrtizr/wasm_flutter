import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_wasm_test/global.dart';
import 'package:mobile_wasm_test/wallet.dart';
import 'package:mobile_wasm_test/wasm_provider.dart';
import 'package:wasm_run_flutter/wasm_run_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final wasmProvider = WasmProvider();
  final String _passPhrase = 'verySecretWord';
  final String _pinCode = '1111';

  WasmInstance? _wasmInstance;
  Wallet? _wallet;

  /// Wallet storage.
  Uint8List? _devicePinBuff;
  Uint8List? _recoverGenBuff;
  Uint8List? _accountBuff;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadWasm() async {
    if (_wasmInstance == null) {
      print('Loading wasm ...');
      _wasmInstance = await wasmProvider.loadWasmFile();
      _wallet = Wallet(_wasmInstance!);
    }
  }

  Future<void> _createWallet() async {
    await _loadWasm();
    print('Creating a wallet ...');
    int walletCreateResult = _wallet!.createWallet(_passPhrase, _pinCode);
    print('Wallet create result: $walletCreateResult');
    int loginResult = _wallet!.login(_pinCode);
    print('Wallet login result: $loginResult');

    var pubKey = _wallet!.getPublicKey();
    print('PublicKey: ${base64Url.encode(pubKey.toList())}');

    _wallet?.addTestAmount(10000);

    _devicePinBuff = _wallet!.getDevicePin();
    _recoverGenBuff = _wallet!.getRecoverGen();
    _accountBuff = _wallet!.getAccount();

    print('Device len: ${_devicePinBuff!.toList().length}');
    print('Recover len: ${_recoverGenBuff!.toList().length}');
    print('Account len: ${_accountBuff!.toList().length}');
  }

  Future<void> _loadWallet() async {
    await _loadWasm();
    print('Loading a wallet ...');
    int reaedWalletResult = _wallet!.readWallet(
      _devicePinBuff!,
      _recoverGenBuff!,
      _accountBuff!,
    );
    print('Read wallet result: $reaedWalletResult');

    int loginResult = _wallet!.login(_pinCode);
    print('Wallet login result: $loginResult');
    var pubKey = _wallet?.getPublicKey();
    print('PublicKey: ${base64Url.encode(pubKey!.toList())}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '...',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _loadWasm,
            tooltip: 'Load',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 10.0),
          FloatingActionButton(
            onPressed: _createWallet,
            tooltip: 'Create',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10.0),
          FloatingActionButton(
            onPressed: _loadWallet,
            tooltip: 'Load',
            child: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
}
