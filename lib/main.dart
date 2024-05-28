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
  final String _wasmFilePath = 'assets/wasm/tauon_test.wasm';

  WasmInstance? _wasmInstance;
  // Wallet? _wallet;

  /// Wallet storage.
  Uint8List? _devicePinBuff;
  Uint8List? _recoverGenBuff;
  Uint8List? _accountBuff;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initWasm() async {
    if (_wasmInstance == null) {
      print('Init wallet ...');
      _wasmInstance = await wasmProvider.createInstance(_wasmFilePath);
    }
  }

  Future<void> _createWallet() async {
    await _initWasm();
    print('Creating a wallet ...');
    Wallet wallet = Wallet(_wasmInstance!);
    int walletCreateResult = wallet.createWallet(_passPhrase, _pinCode);
    print('Wallet create result: $walletCreateResult');
    int loginResult = wallet.login(_pinCode);
    print('Wallet login result: $loginResult');

    var pubKey = wallet.getPublicKey();
    print('PublicKey: ${base64Url.encode(pubKey.toList())}');

    wallet.addTestAmount(10000);

    _devicePinBuff = wallet.getDevicePin()['data'];
    _recoverGenBuff = wallet.getRecoverGen()['data'];
    _accountBuff = wallet.getAccount()['data'];
    print('_devicePinBuff ${base64Url.encode(_devicePinBuff!)}');
    print('_recoverGenBuff ${base64Url.encode(_recoverGenBuff!)}');
    print('_accountBuff ${base64Url.encode(_accountBuff!)}');

    print('Device len: ${_devicePinBuff!.toList().length}');
    print('Recover len: ${_recoverGenBuff!.toList().length}');
    print('Account len: ${_accountBuff!.toList().length}');
  }

  Future<void> _loadWallet() async {
    await _initWasm();
    print('Loading a wallet ...');
    Wallet wallet = Wallet(_wasmInstance!);
    // int reaedWalletResult = wallet.readWallet(
    //   _devicePinBuff!,
    //   _recoverGenBuff!,
    //   _accountBuff!,
    // );
    int reaedWalletResult = wallet.readWallet(
      base64Url.decode(deviceBase64),
      base64Url.decode(recoverBase64),
      base64Url.decode(accountBase64),
    );
    print('Read wallet result: $reaedWalletResult');

    int loginResult = wallet.login(_pinCode);
    print('Wallet login result: $loginResult');
    var pubKey = wallet.getPublicKey();
    print('PublicKey: ${base64Url.encode(pubKey.toList())}');
  }

  Future<void> createWalletInline() async {
    await _initWasm();
    print('Creating a wallet ...');
    Wallet wallet1 = Wallet(wasmProvider.instance);
    int walletCreateResult = wallet1.createWallet(_passPhrase, _pinCode);
    print('Wallet create result: $walletCreateResult');
    int loginResult = wallet1.login(_pinCode);
    print('Wallet login result: $loginResult');

    var pubKey = wallet1.getPublicKey();
    print('PublicKey: ${base64Url.encode(pubKey.toList())}');

    wallet1.addTestAmount(10000);

    final devicePin = wallet1.getDevicePin();
    final recoverGen = wallet1.getRecoverGen();
    final account = wallet1.getAccount();

    Wallet wallet2 = Wallet(wasmProvider.instance);

    print('Loading a wallet ...');
    int readWalletResult = wallet2.readWalletPtrs(
      devicePin['ptr'],
      devicePin['len'],
      recoverGen['ptr'],
      recoverGen['len'],
      account['ptr'],
      account['len'],
    );
    print('Read wallet result: $readWalletResult');
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
            onPressed: _initWasm,
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
