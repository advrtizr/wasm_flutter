import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_wasm_test/wallet.dart';
import 'package:mobile_wasm_test/wasm_provider.dart';

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
  // final String _passPhrase = 'apple banana carpet dolphin elephant ferris giraffe honey igloo jelly kangaroo lemon';
  final String _passPhrase = 'verySecretWord';
  final String _pinCode = '1111';
  final String _wasmFilePath = 'assets/wasm/tauon_test.wasm';

  bool _isInstanceCreated = false;

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
    if (!_isInstanceCreated) {
      print('Init wallet ...');
      await wasmProvider.createInstance(_wasmFilePath);
      _isInstanceCreated = true;
    }
  }

  Future<void> _createWallet() async {
    await _initWasm();
    print('Creating a wallet ...');
    final wallet = Wallet(wasmProvider.instance);

    // var res = wallet.checkStr('Hello World!');
    // print('CheckStr result: $res');
    int walletCreateResult = wallet.createWallet(_passPhrase, _pinCode);
    print('Wallet create result: $walletCreateResult');
    int loginResult = wallet.login(_pinCode);
    print('Wallet login result: $loginResult');

    var pubKey = wallet.getPublicKey();
    print('PublicKey: ${base64Url.encode(pubKey.toList())}');

    // wallet.addTestAmount(10000);

    _devicePinBuff = wallet.getDevicePin()['data'];
    _recoverGenBuff = wallet.getRecoverGen()['data'];
    _accountBuff = wallet.getAccount()['data'];

    _devicePinBase64 = base64Url.encode(_devicePinBuff!);
    _recoverGenBase64 = base64Url.encode(_recoverGenBuff!);
    _accountBase64 = base64Url.encode(_accountBuff!);

    print('_devicePinBase64 $_devicePinBase64');
    print('_recoverGenBase64 $_recoverGenBase64');
    print('_accountBase64 $_accountBase64');
  }

  Future<void> _loadWallet() async {
    await _initWasm();
    print('Loading a wallet ...');
    final wallet = Wallet(wasmProvider.instance);

    _devicePinBuff = base64Url.decode(_devicePinBase64!);
    _recoverGenBuff = base64Url.decode(_recoverGenBase64!);
    _accountBuff = base64Url.decode(_accountBase64!);

    int readWalletResult = wallet.readWallet(_devicePinBuff!, _recoverGenBuff!, _accountBuff!);
    print('Read wallet result: $readWalletResult');

    int loginResult = wallet.login(_pinCode);
    print('Wallet login result: $loginResult');
    var pubKey = wallet.getPublicKey();
    print('PublicKey: ${base64Url.encode(pubKey.toList())}');
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
        ],
      ),
    );
  }
}
