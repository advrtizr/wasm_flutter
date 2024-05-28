import 'dart:convert';
import 'dart:typed_data';

import 'package:wasm_run_flutter/wasm_run_flutter.dart';

class Hibon {
  static const int hibonSize = 4 + 4; //8 bytes
  late final WasmInstance _instance;
  int thisPtr = 0;

  Hibon(WasmInstance instance) {
    _instance = instance;
    final WasmFunction mymallocFunc = _instance.getFunction('mymalloc')!;
    final WasmFunction createHibonFunc = _instance.getFunction('tagion_hibon_create')!;
    thisPtr = mymallocFunc.inner(hibonSize);
    createHibonFunc.inner(thisPtr);
  }

  Map<String, dynamic> _allocateStr(String str) {
    List<int> encoded = utf8.encode(str);

    final WasmFunction mymallocFunc = _instance.getFunction('mymalloc')!;
    final strPtr = mymallocFunc.inner(encoded.length);

    final memory = _instance.getMemory('memory');
    memory?.view.setAll(strPtr, encoded);
    return {
      'encoded': encoded,
      'ptr': strPtr,
      'len': encoded.length,
    };
  }

  int addString(key, value) {
    final keyAlloc = _allocateStr(key);
    final valueAlloc = _allocateStr(value);
    final WasmFunction addStringFunc = _instance.getFunction('tagion_hibon_add_string')!;
    final result = addStringFunc.inner(
      thisPtr,
      keyAlloc['ptr'],
      keyAlloc['len'],
      valueAlloc['ptr'],
      valueAlloc['len'],
    );
    return result;
  }

  int addBool(String key, bool value) {
    final keyAlloc = _allocateStr(key);
    final WasmFunction addBoolFunc = _instance.getFunction('tagion_hibon_add_bool')!;
    final result = addBoolFunc.inner(
      thisPtr,
      keyAlloc['ptr'],
      keyAlloc['len'],
      value ? 1 : 0,
    );
    return result;
  }

  int addInt32(String key, int value) {
    final keyAlloc = _allocateStr(key);
    final WasmFunction addInt32Func = _instance.getFunction('tagion_hibon_add_int32')!;
    final result = addInt32Func.inner(
      thisPtr,
      keyAlloc['ptr'],
      keyAlloc['len'],
      value,
    );
    return result;
  }

  int addInt64(String key, int value) {
    final keyAlloc = _allocateStr(key);

    final WasmFunction mymallocFunc = _instance.getFunction('mymalloc')!;
    final valuePtr = mymallocFunc.inner(8);

    final memory = _instance.getMemory('memory');
    memory?.view.buffer.asByteData().setInt64(valuePtr, value);

    final WasmFunction addInt64Func = _instance.getFunction('tagion_hibon_add_array_int64')!;
    final result = addInt64Func.inner(
      thisPtr,
      keyAlloc['ptr'],
      keyAlloc['len'],
      valuePtr,
      8,
    );
    return result;
  }

  String toPretty() {
    const textFormat = 1;
    final strPtrPtr = _instance.getFunction('mymalloc')?.inner(4);
    final strLenPtr = _instance.getFunction('mymalloc')?.inner(4);

    _instance.getFunction('tagion_hibon_get_text')?.inner(thisPtr, textFormat, strPtrPtr, strLenPtr);

    final memory = _instance.getMemory('memory');
    if (memory == null) {
      return '';
    }

    Uint32List strPtr = Uint32List.view(memory.view.buffer, strPtrPtr, 1);
    Uint32List strLen = Uint32List.view(memory.view.buffer, strLenPtr, 1);

    return utf8.decode(memory.view.buffer.asUint8List(strPtr[0], strLen[0]));
  }
}
