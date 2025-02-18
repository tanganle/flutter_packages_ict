import 'dart:async';
import 'dart:io';
import '../config/config.dart';

class UDPClient {
  factory UDPClient() => _getInstance();
  static UDPClient get instance => _getInstance();
  static UDPClient? _instance;
  late RawDatagramSocket udpSocket;
  //蓝牙接收数据控制流
  final StreamController<List<int>> _getDataController =
      StreamController.broadcast(); //监听数据流的控制器
  StreamController get getDataController => _getDataController; //获取数据流的控制器

  //初始化
  static UDPClient _getInstance() {
    _instance ??= UDPClient._internal();
    return _instance!;
  }

  //初始化
  UDPClient._internal() {
    (InternetAddress.lookup('pool.ntp.org')).then((value) {
      var serverAddress = value.first;
      // print("获取到的数据:----${serverAddress.type}-----${InternetAddress.anyIPv4}");
      RawDatagramSocket.bind(
              serverAddress.type == InternetAddressType.IPv6
                  ? InternetAddress.anyIPv6
                  : InternetAddress.anyIPv4,
              0)
          .then((value) {
        udpSocket = value;
        udpSocket.listen(handleUDPDatagram);
        udpSocket.broadcastEnabled = true;
      });
    });
  }
  //断开连接
  void disconnectFromUDP() {
    udpSocket.close();
    _instance = null;
  }

  //监听到的数据
  void handleUDPDatagram(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram? datagram = udpSocket.receive();
      if (datagram != null) {
        List<int> data = datagram.data;
        // print("广播接收内容:$data");
        _getDataController.sink.add(data);
      }
    }
  }

  //发送数据
  void sendUDPData(
    List<int> data, {
    String ip = '255.255.255.255',
  }) {
    int port = Config.instance.UDP_PORT;
    print("${InternetAddress(ip)}");
    udpSocket.send(data, InternetAddress(ip), port);
  }
}
