import 'dart:convert';
import 'dart:typed_data';
import 'package:wasm_run_flutter/wasm_run_flutter.dart';

class Wallet {
  static const int walletSize = 16; //bytes

  late final WasmInstance _instance;
  late int _thisPtr;

  Wallet(WasmInstance instance) {
    _instance = instance;
    _thisPtr = _getPointer(walletSize);
    _instance.getFunction('tagion_wallet_create_instance')!.inner(_thisPtr);
    // _instance.getMemory('memory')?.grow(500); // 1000 = exception
  }

  // Pointer ops.
  int _getPointer(int size) {
    final WasmFunction mymallocFunc = _instance.getFunction('mymalloc')!;
    return mymallocFunc.inner(size);
  }

  void _freePointer(int ptr) {
    _instance.getFunction('mydealloc')!.inner(ptr);
  }

  Map<String, dynamic> _allocate(List<int> toAlloc) {
    final toAllocPtr = _getPointer(toAlloc.length);
    WasmMemory? memory = _instance.getMemory('memory');
    if (memory == null) throw Exception();

    memory.view.setAll(toAllocPtr, toAlloc);

    return {
      'ptr': toAllocPtr,
      'len': toAlloc.length,
    };
  }

  Map<String, dynamic> _allocateStr(String str) {
    return _allocate(utf8.encode(str));
  }

  Uint8List _getAllocated(int ptr, int len) {
    final wasmMemory = _instance.getMemory('memory');

    if (wasmMemory == null) {
      throw Exception('Memory is not found');
    }

    Uint32List ptrInMem = Uint32List.view(wasmMemory.view.buffer, ptr, 1);
    Uint32List lenInMem = Uint32List.view(wasmMemory.view.buffer, len, 1);

    return wasmMemory.view.buffer.asUint8List(ptrInMem[0], lenInMem[0]);
  }

  int createWallet(String passphrase, String pincode) {
    final passphraseAlloc = _allocateStr(passphrase);
    final pincodeAlloc = _allocateStr(pincode);
    final WasmFunction createWalletFunc = _instance.getFunction('tagion_wallet_create_wallet')!;
    final status = createWalletFunc.inner(
      _thisPtr,
      passphraseAlloc['ptr'],
      passphraseAlloc['len'],
      pincodeAlloc['ptr'],
      pincodeAlloc['len'],
    );
    _freePointer(passphraseAlloc['ptr']);
    _freePointer(pincodeAlloc['ptr']);
    return status;
  }

  int login(String pincode) {
    final pincodeAlloc = _allocateStr(pincode);
    final WasmFunction loginFunc = _instance.getFunction('tagion_wallet_login')!;
    final status = loginFunc.inner(_thisPtr, pincodeAlloc['ptr'], pincodeAlloc['len']);
    _freePointer(pincodeAlloc['ptr']);
    return status;
  }

  int readWallet(
    Uint8List devicePin,
    Uint8List recoverGen,
    Uint8List account,
  ) {
    final devicePinAlloc = _allocate(devicePin);
    final accountAlloc = _allocate(account);
    final recoverGenAlloc = _allocate(recoverGen);

    int status = _instance.getFunction('tagion_wallet_read_wallet')!.inner(
          _thisPtr,
          devicePinAlloc['ptr'],
          devicePinAlloc['len'],
          recoverGenAlloc['ptr'],
          recoverGenAlloc['len'],
          accountAlloc['ptr'],
          accountAlloc['len'],
        );

    _freePointer(devicePinAlloc['ptr']);
    _freePointer(recoverGenAlloc['ptr']);
    _freePointer(accountAlloc['ptr']);
    return status;
  }

  Uint8List getDevicePin() {
    final devicePinPtrPtr = _getPointer(4);
    final devicePinLenPtr = _getPointer(4);

    _instance.getFunction('tagion_wallet_get_device_pin')!.inner(_thisPtr, devicePinPtrPtr, devicePinLenPtr);

    final data = _getAllocated(devicePinPtrPtr, devicePinLenPtr);
    _freePointer(devicePinPtrPtr);
    _freePointer(devicePinLenPtr);
    return data;
  }

  Uint8List getRecoverGen() {
    final recoverGenPtrPtr = _getPointer(4);
    final recoverGenLenPtr = _getPointer(4);

    _instance.getFunction('tagion_wallet_get_recover_generator')!.inner(_thisPtr, recoverGenPtrPtr, recoverGenLenPtr);
    final data = _getAllocated(recoverGenPtrPtr, recoverGenLenPtr);
    _freePointer(recoverGenPtrPtr);
    _freePointer(recoverGenLenPtr);
    return data;
  }

  Uint8List getAccount() {
    final accountPtrPtr = _getPointer(4);
    final accountLenPtr = _getPointer(4);

    _instance.getFunction('tagion_wallet_get_account')!.inner(_thisPtr, accountPtrPtr, accountLenPtr);
    final data = _getAllocated(accountPtrPtr, accountLenPtr);
    _freePointer(accountPtrPtr);
    _freePointer(accountLenPtr);
    return data;
  }

  Uint8List getPublicKey() {
    final publicKeyPtrPtr = _getPointer(4);
    final publicKeyLenPtr = _getPointer(4);
    _instance.getFunction('tagion_wallet_get_current_pkey')!.inner(_thisPtr, publicKeyPtrPtr, publicKeyLenPtr);

    final data = _getAllocated(publicKeyPtrPtr, publicKeyLenPtr);
    _freePointer(publicKeyPtrPtr);
    _freePointer(publicKeyLenPtr);
    return data;
  }

  void addTestAmount(double amount) {
    int status = _instance.getFunction('tagion_wallet_force_bill')!.inner(_thisPtr, amount);
    print('Add amount to the wallet: $status');
  }
}
