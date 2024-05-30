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
    instance.getFunction('tagion_wallet_create_instance')!.inner(_thisPtr);
  }

  // Pointer ops.
  int _getPointer(int size) {
    // final WasmFunction mymallocFunc = _instance.getFunction('mymalloc')!;
    final WasmFunction mymallocFunc = _instance.getFunction('gc_malloc')!;
    return mymallocFunc.inner(size);
  }

  void _freePointer(int ptr) {
    // _instance.getFunction('mydealloc')!.inner(ptr);
    _instance.getFunction('gc_free')!.inner(ptr);
  }

  Map<String, dynamic> allocate(Uint8List toAlloc) {
    return _allocate(toAlloc);
  }

  void freePtr(int ptr) {
    _freePointer(ptr);
  }

  Map<String, dynamic> _allocate(Uint8List toAlloc) {
    final toAllocPtr = _getPointer(toAlloc.lengthInBytes);
    WasmMemory? memory = _instance.getMemory('memory');

    if (memory == null) {
      throw Exception('Memory is not found');
    }

    memory.view.setAll(toAllocPtr, toAlloc);

    return {
      'ptr': toAllocPtr,
      'len': toAlloc.lengthInBytes,
    };
  }

  Map<String, dynamic> _allocateStr(String str) {
    return _allocate(Uint8List.fromList(utf8.encode(str)));
  }

  Uint8List _getAllocated(int ptr, int len) {
    final memory = _instance.getMemory('memory');

    if (memory == null) {
      throw Exception('Memory is not found');
    }

    Uint32List ptrInMem = Uint32List.view(memory.view.buffer, ptr, 1);
    Uint32List lenInMem = Uint32List.view(memory.view.buffer, len, 1);

    return memory.view.buffer.asUint8List(ptrInMem[0], lenInMem[0]);
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

    int status = readWalletPtrs(
      devicePinAlloc['ptr'],
      devicePinAlloc['len'],
      recoverGenAlloc['ptr'],
      recoverGenAlloc['len'],
      accountAlloc['ptr'],
      accountAlloc['len'],
    );

    return status;
  }

  int readWalletPtrs(
    int devicePinPtr,
    int devicePinLen,
    int recoverGenPtr,
    int recoverGenLen,
    int accountPtr,
    int accountLen,
  ) {
    int status = _instance.getFunction('tagion_wallet_read_wallet')!.inner(
          _thisPtr,
          devicePinPtr,
          devicePinLen,
          recoverGenPtr,
          recoverGenLen,
          accountPtr,
          accountLen,
        );
    _freePointer(devicePinPtr);
    _freePointer(recoverGenPtr);
    _freePointer(accountPtr);
    return status;
  }

  Map<String, dynamic> getDevicePin() {
    final devicePinPtrPtr = _getPointer(4);
    final devicePinLenPtr = _getPointer(4);

    _instance.getFunction('tagion_wallet_get_device_pin')!.inner(_thisPtr, devicePinPtrPtr, devicePinLenPtr);

    final data = _getAllocated(devicePinPtrPtr, devicePinLenPtr);
    _freePointer(devicePinPtrPtr);
    _freePointer(devicePinLenPtr);
    return {'data': data, 'ptr': devicePinPtrPtr, 'len': devicePinLenPtr};
  }

  Map<String, dynamic> getRecoverGen() {
    final recoverGenPtrPtr = _getPointer(4);
    final recoverGenLenPtr = _getPointer(4);

    _instance.getFunction('tagion_wallet_get_recover_generator')!.inner(_thisPtr, recoverGenPtrPtr, recoverGenLenPtr);
    final data = _getAllocated(recoverGenPtrPtr, recoverGenLenPtr);
    _freePointer(recoverGenPtrPtr);
    _freePointer(recoverGenLenPtr);
    return {'data': data, 'ptr': recoverGenPtrPtr, 'len': recoverGenLenPtr};
  }

  Map<String, dynamic> getAccount() {
    final accountPtrPtr = _getPointer(4);
    final accountLenPtr = _getPointer(4);

    _instance.getFunction('tagion_wallet_get_account')!.inner(_thisPtr, accountPtrPtr, accountLenPtr);
    final data = _getAllocated(accountPtrPtr, accountLenPtr);
    _freePointer(accountPtrPtr);
    _freePointer(accountLenPtr);
    return {'data': data, 'ptr': accountPtrPtr, 'len': accountLenPtr};
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
