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

  String? _devicePinBase64;
  String? _recoverGenBase64;
  String? _accountBase64;

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
    final wallet = Wallet(_wasmInstance!);
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

    _devicePinBase64 = base64Url.encode(_devicePinBuff!);
    _recoverGenBase64 = base64Url.encode(_recoverGenBuff!);
    _accountBase64 = base64Url.encode(_accountBuff!);

    print('_devicePinBase64 $_devicePinBase64');
    print('_recoverGenBase64 $_recoverGenBase64');
    print('_accountBase64 $_accountBase64');

    print('Device len: ${_devicePinBuff!.toList().length}');
    print('Recover len: ${_recoverGenBuff!.toList().length}');
    print('Account len: ${_accountBuff!.toList().length}');
  }

  Future<void> _loadWallet() async {
    await _initWasm();
    print('Loading a wallet ...');
    final wallet = Wallet(_wasmInstance!);
    // int readWalletResult = wallet.readWallet(
    //   _devicePinBuff!,
    //   _recoverGenBuff!,
    //   _accountBuff!,
    // );

    /// load data saved in global.dart.
    int readWalletResult = wallet.readWallet(
      base64Url.decode(deviceBase64),
      base64Url.decode(recoverBase64),
      base64Url.decode(accountBase64),
    );
    print('Read wallet result: $readWalletResult');

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

  void _testAllocation() async {
    await _initWasm();
    final wallet = Wallet(wasmProvider.instance);

    // dummy data.
    final list1 = List.generate(117, (i) => i + 1);
    final list2 = List.generate(56, (i) => i + 1);
    final list3 = List.generate(307, (i) => i + 1);

    // real data.
    final data1 = base64Url.decode(deviceBase64);
    final data2 = base64Url.decode(recoverBase64);
    final data3 = base64Url.decode(accountBase64);

    var alloc1 = wallet.allocate(data1);
    var alloc2 = wallet.allocate(data2);
    var alloc3 = wallet.allocate(data3);

    print('allocate1: ${alloc1['ptr']}, ${alloc1['len']}');
    print('allocate2: ${alloc2['ptr']}, ${alloc2['len']}');
    print('allocate3: ${alloc3['ptr']}, ${alloc3['len']}');

    // wallet.freePtr(alloc1['ptr']);
    // wallet.freePtr(alloc2['ptr']);
    // wallet.freePtr(alloc3['ptr']);

    // Caused by:
    // wasm trap: wasm `unreachable` instruction executed)
    int result = wallet.readWalletPtrs(
      alloc1['ptr'],
      alloc1['len'],
      alloc2['ptr'],
      alloc2['len'],
      alloc3['ptr'],
      alloc3['len'],
    );

    print('readWalletPtrs result: $result');
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
          const SizedBox(height: 10.0),
          FloatingActionButton(
            onPressed: _testAllocation,
            tooltip: 'Load',
            child: const Icon(Icons.file_copy),
          ),
        ],
      ),
    );
  }
}
