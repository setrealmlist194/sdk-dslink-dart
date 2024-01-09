import 'dart:typed_data';

BigInt readBytes(Uint8List bytes) {
  var result = BigInt.zero;
  for (int i = 0; i < bytes.length; ++i) {
    result = result << 8;
    var x = bytes[i];
    result += new BigInt.from(x);
  }
  return result;
}


List<int> bigIntToBytes(BigInt data) {
  String str;
  bool neg = false;
  if (data < BigInt.zero) {
    str = (~data).toRadixString(16);
    neg = true;
  } else {
    str = data.toRadixString(16);
  }
  int p = 0;
  int len = str.length;

  int blen = (len + 1) ~/ 2;
  int boff = 0;
  late List<int> bytes;
  if (neg) {
    if (len & 1 == 1) {
      p = -1;
    }
    int byte0 = ~int.parse(str.substring(0, p + 2), radix: 16);
    if (byte0 < -128) byte0 += 256;
    if (byte0 >= 0) {
      boff = 1;
      bytes = List<int>.filled(blen + 1, 0);
      bytes[0] = -1;
      bytes[1] = byte0;
    } else {
      bytes = List<int>.filled(blen, 0);
      bytes[0] = byte0;
    }
    for (int i = 1; i < blen; ++i) {
      int byte = ~int.parse(str.substring(p + (i << 1), p + (i << 1) + 2),
          radix: 16);
      if (byte < -128) byte += 256;
      bytes[i + boff] = byte;
    }
  } else {
    if (len & 1 == 1) {
      p = -1;
    }
    int byte0 = int.parse(str.substring(0, p + 2), radix: 16);
    if (byte0 > 127) byte0 -= 256;
    if (byte0 < 0) {
      boff = 1;
      bytes = List<int>.filled(blen + 1, 0);
      bytes[0] = 0;
      bytes[1] = byte0;
    } else {
      bytes = List<int>.filled(blen, 0);
      bytes[0] = byte0;
    }
    for (int i = 1; i < blen; ++i) {
      int byte =
      int.parse(str.substring(p + (i << 1), p + (i << 1) + 2), radix: 16);
      if (byte > 127) byte -= 256;
      bytes[i + boff] = byte;
    }
  }
  return bytes;
}

