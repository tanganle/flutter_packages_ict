import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:ict_all/utils/fun.dart';
import 'package:ict_all/utils/udp.dart';
import 'package:ict_all/coap/coap_client.dart';

///macStr 是测试的,后期要改
class CoapClientPackage extends StatefulWidget {
  const CoapClientPackage({
    super.key,
    this.mac = '11:22:33:44:55:66',
    required this.widget,
  });
  final String mac;
  final Widget widget;

  @override
  State<CoapClientPackage> createState() => CoapClientPackageState();
}

class CoapClientPackageState extends State<CoapClientPackage> {
  StreamSubscription? _networkStatusSubscription; //监听设备的网络类型
  CoapClientUtil? coapClient;

  //udp获取到的数据
  UDPClient? udpClient;
  StreamSubscription? _sacnSubscription;
  bool isCoap = false;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    // initUDP();

    // //监听移动终端联网方式
    // _listenNetworkStatus();
    getinitState();
  }

  getinitState() {
    print("初始化");
    initUDP();
    //监听移动终端联网方式
    _listenNetworkStatus();
  }

  setDispose() {
    print("移除");
    _networkStatusSubscription?.cancel(); //取消监听
    coapClient?.disply(); //关闭coap连接
    udpClient?.disconnectFromUDP(); //关闭udp连接
    _sacnSubscription?.cancel(); //取消监听
    timer?.cancel(); //取消定时器
  }

  @override
  void dispose() {
    setDispose();
    super.dispose();
  }

  initUDP() {
    udpClient = UDPClient.instance;
    _sacnSubscription?.cancel();
    _sacnSubscription = udpClient?.getDataController.stream.listen((data) {
      if (data is List<int>) {
        print("这是哪个数据:$data");
        setState(() {
          isCoap = false;
        });
        switch (data[2]) {
          case 129: //
            if (data[0] == 170 && data.length == 15 && data[14] == 85) {
              //将从data[7]开始截取数组
              // List macArr = data.sublist(3, 9); //截取mac地址
              // //将十进制数组转换成十六进制mac并添加:
              // String macStr =
              //     macArr.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');
              // print("macArr:$macArr -----${macStr}");
              timer?.cancel();
              String serverIp =
                  "${data[9]}.${data[10]}.${data[11]}.${data[12]}";

              print("获取到了ip地址:$serverIp");
              //创建一个coap服务
              coapClient = CoapClientUtil(
                host: serverIp,
                port: 5683,
              );
              setState(() {
                isCoap = true;
              });
            }

            break;
          default:
        }
      }
    });
  }

  //监听移动终端联网方式
  void _listenNetworkStatus() async {
    _networkStatusSubscription?.cancel(); //取消之前的监听
    bool isWif = await isWifi();
    if (isWif) {
      isWifiAfter();
    } else {
      _networkStatusSubscription = Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> result) {
        // if (result == ConnectivityResult.wifi) {
        //   //当前的类型是WiFi
        //   isWifiAfter();
        // } else {
        //   setState(() {
        //     isCoap = false;
        //   });
        // }
      });
    }
  }

  isWifiAfter() {
    print('当前的类型是WiFi');

    //这里需要在发送mac地址,这里使用模拟的数据
    String macStr = widget.mac;
    // String macStr = '11:22:33:44:55:66';

    //将macStr装换成List<int>
    List<int> macArr =
        macStr.split(':').map((e) => int.parse(e, radix: 16)).toList();
    List<int> sendData = sendCoapData('01', macArr);
    print("-----=====------macArr:${sendData},macStr");
    Timer(Duration(seconds: 1), () {
      udpClient?.sendUDPData(sendData);
    });
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (udpClient != null) {
        try {
          udpClient?.sendUDPData(sendData);
        } catch (e) {
          print("发送出现了问题:${e}");
        }
      } else {
        print("为空");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.widget;
  }
}
