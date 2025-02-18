import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ict_all/ble/ble.dart';

/// Esp32蓝牙数据处理
class Esp32Handle {
  static Esp32Handle? _instance;
  //蓝牙连接发送数据序列号
  int _sequence = -1;
  // 蓝牙连接状态流订阅
  StreamSubscription? _connectionSubscription;

  static Esp32Handle get instance {
    if (_instance == null) {
      _instance = Esp32Handle._init();
    }
    return _instance!;
  }

  _getSequence() {
    _sequence = _sequence + 1;
    if (_sequence > 255) {
      _sequence = 0;
    }
    return _sequence;
  }

  Esp32Handle._init() {
    subscription();
  }

  /// 取消连接状态订阅
  void unsubscription() {
    _sequence = -1;
    _connectionSubscription?.cancel();
  }

  /// 订阅连接状态
  void subscription() {
    _connectionSubscription =
        Ble.instance.connectController.stream.listen((event) {
      switch (event) {
        case BluetoothConnectionState.connected:
          _sequence = -1;
          break;
        case BluetoothConnectionState.disconnected:
          _sequence = -1;
          break;
        default:
      }
    });
  }

  /// Esp32发送数据
  /// command, ESP32的控制命令,必须是8个字节 例如 4D08
  /// arr, 需要发送的数据
  /// sequence, 帧序列号
  List<int> sendDataESP32(String command, List<int> data) {
    List<int> sendArr = [];
    //帧长,如果帧长是一位,前面加0
    command = command.padLeft(4, '0');

    List<int> commandArr = [];
    for (int i = 0; i < command.length; i += 2) {
      int endIndex = i + 2;
      if (endIndex > command.length) {
        endIndex = command.length;
      }
      String subString = command.substring(i, endIndex);
      int subInt = int.parse(subString, radix: 16);
      commandArr.add(subInt);
    }

    int length = data.length;

    sendArr = commandArr + [_getSequence()] + [length] + data;
    return sendArr;
    // print('发送的数据:$sendArr');
    // print('发送的数据16:$dataArr');

    // Timer(Duration(milliseconds: 50), () {
    //   print("发送的数据:$sendArr");
    //   ble1.writeWithOut(sendArr);
    // });
  }

  /// 处理广播数据
  /// 返回值：设备的mac地址
  Object handleDataByAdvertisement(Map<int, List<int>> data) {
    List<int> manufacturerDataArr = [];
    data.forEach((key, value) {
      String data16 = key.toRadixString(16).padLeft(4, "0");
      int two = int.parse(data16.substring(0, 2), radix: 16);
      int one = int.parse(data16.substring(2, 4), radix: 16);
      manufacturerDataArr.add(one);
      manufacturerDataArr.add(two);
      manufacturerDataArr.addAll(value);
    });
    String mac = "";
    for (int i = 2; i < 8; i++) {
      String str = manufacturerDataArr[i].toRadixString(16).padLeft(2, '0');
      if (i == 7) {
        mac += str;
      } else {
        mac += "$str:";
      }
    }
    return mac;
  }
}
