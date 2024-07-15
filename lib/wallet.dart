import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:wasm_run_flutter/wasm_run_flutter.dart';

class Wallet {
  final int walletSize = 128; // bytes
  final int dataSize = sizeOf<Uint8>(); // 4 bytes

  late final WasmInstance _instance;
  late int _thisPtr;
  bool _isInstanceCreated = false;

  Wallet(WasmInstance instance) {
    _instance = instance;
    _thisPtr = _getPointer(walletSize);
    _isInstanceCreated = instance.getFunction('tagion_wallet_create_instance')!.inner(_thisPtr) == 0;
    print('Wallet _thisPtr $_thisPtr');
    print('Wallet _isInstanceCreated $_isInstanceCreated');
  }

  // Pointer ops.
  int _getPointer(int size) {
    // print('_getPointer mymalloc size $size');
    return _instance.getFunction('mymalloc')!.inner(size);
  }

  void _freePointer(int ptr) {
    // print('_freePointer $ptr');
    _instance.getFunction('mydealloc')!.inner(ptr);
  }

  Map<String, dynamic> allocate(Uint8List toAlloc) {
    return _allocate(toAlloc);
  }

  void freePtr(int ptr) {
    _freePointer(ptr);
  }

  Map<String, dynamic> _allocate(Uint8List toAlloc) {
    // Ensure to get the correct pointer from the WASM instance
    final int toAllocPtr = _getPointer(toAlloc.lengthInBytes);
    WasmMemory? memory = _instance.getMemory('memory');

    if (memory == null) {
      throw Exception('Memory not found');
    }

    // memory.view.setAll(toAllocPtr, toAlloc);

    // Ensure the memory view is correctly accessed
    for (int i = 0; i < toAlloc.lengthInBytes; i++) {
      memory.view[toAllocPtr + i] = toAlloc[i];
    }

    print('ptrInMem $toAllocPtr lenInMem ${toAlloc.lengthInBytes}');

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

    final ptrInMem = Uint32List.view(memory.view.buffer, ptr, 1)[0];
    final lenInMem = Uint32List.view(memory.view.buffer, len, 1)[0];

    print('ptrInMem $ptrInMem lenInMem $lenInMem');

    return memory.view.buffer.asUint8List(ptrInMem, lenInMem);
  }

  // Uint8List _getAllocated(int ptr, int len) {
  //   final memory = _instance.getMemory('memory');

  //   if (memory == null) {
  //     throw Exception('Memory not found');
  //   }

  //   return memory.view.buffer.asUint8List(ptr, len);
  // }

  void checkStr(Uint8List data) {
    final dataAlloc = _allocate(data);
    print('checkStr dataAlloc ${dataAlloc['ptr']}');
    Uint8List memData = _getAllocated(dataAlloc['ptr'], dataAlloc['len']);
    print('checkStr data == memData ${listEquals(data, memData)}');
    _freePointer(dataAlloc['ptr']);
  }

  int createWallet(String passphrase, String pincode) {
    if (!_isInstanceCreated) return -1;
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
    if (!_isInstanceCreated) return -1;
    final devicePinAlloc = _allocate(devicePin);
    final recoverGenAlloc = _allocate(recoverGen);
    final accountAlloc = _allocate(account);

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
    print('readWalletPtrs _thisPtr $_thisPtr');
    print('readWalletPtrs devicePinPtr $devicePinPtr devicePinLen $devicePinLen');
    print('readWalletPtrs recoverGenPtr $recoverGenPtr recoverGenLen $recoverGenLen');
    print('readWalletPtrs accountPtr $accountPtr accountLen $accountLen');

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
    final devicePinPtrPtr = _getPointer(dataSize);
    final devicePinLenPtr = _getPointer(dataSize);

    _instance.getFunction('tagion_wallet_get_device_pin')!.inner(_thisPtr, devicePinPtrPtr, devicePinLenPtr);

    final data = _getAllocated(devicePinPtrPtr, devicePinLenPtr);
    _freePointer(devicePinPtrPtr);
    _freePointer(devicePinLenPtr);
    return {'data': data, 'ptr': devicePinPtrPtr, 'len': devicePinLenPtr};
  }

  Map<String, dynamic> getRecoverGen() {
    final recoverGenPtrPtr = _getPointer(dataSize);
    final recoverGenLenPtr = _getPointer(dataSize);

    _instance.getFunction('tagion_wallet_get_recover_generator')!.inner(_thisPtr, recoverGenPtrPtr, recoverGenLenPtr);
    final data = _getAllocated(recoverGenPtrPtr, recoverGenLenPtr);
    _freePointer(recoverGenPtrPtr);
    _freePointer(recoverGenLenPtr);
    return {'data': data, 'ptr': recoverGenPtrPtr, 'len': recoverGenLenPtr};
  }

  Map<String, dynamic> getAccount() {
    final accountPtrPtr = _getPointer(dataSize);
    final accountLenPtr = _getPointer(dataSize);

    _instance.getFunction('tagion_wallet_get_account')!.inner(_thisPtr, accountPtrPtr, accountLenPtr);
    final data = _getAllocated(accountPtrPtr, accountLenPtr);
    _freePointer(accountPtrPtr);
    _freePointer(accountLenPtr);
    return {'data': data, 'ptr': accountPtrPtr, 'len': accountLenPtr};
  }

  Uint8List getPublicKey() {
    final publicKeyPtrPtr = _getPointer(dataSize);
    final publicKeyLenPtr = _getPointer(dataSize);
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
