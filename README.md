# ict_all

提供基于Flutter硬件通信的模块，包含蓝牙、wifi、coap、udp的功能，还扩展了ESP32设备的数据处理功能。
***
### 环境说明
- 支持任意版本的低功耗蓝牙
- 支持不同硬件型号的CoAP
- 支持不同硬件型号的UDP
- 支持不同硬件型号的wifi

**蓝牙数据处理支持**

该模块支持的硬件类型蓝牙数据处理如下。
- [x] ESP32
 

### 通信方式
该模块支持的通信方式如下。
- [x] BlueTooth
- [x] CoAP
- [x] UDP

### 通信协议
该模块相关的通信协议如下
- [CoAP通信协议](http://file.nonagon:8090/pages/viewpage.action?pageId=105298964) 
- [蓝牙通信协议](http://file.nonagon:8090/pages/viewpage.action?pageId=105306222) 
- [App与设备通信相关](http://file.nonagon:8090/pages/viewpage.action?pageId=105295815)

### 文件说明
| 文件名称       | 描述                                                      |
| -------------- | --------------------------------------------------------- |
| `config`       | 全局配置，可以设置COAP服务地址、UDP端口 [config](#config) |
| `ble`          | 蓝牙封装类，API参考 [ble API](#ble)                       |
| `esp32_handle` | esp32蓝牙数据处理封装类，API参考 [esp32 API](#esp32)      |
| `coap_client`  | CoAP客户端封装类，API参考 [CoAP API](#CoAP)               |
| `common`       | 系统平台工具类，API参考 [common API](#common)             |
| `date`         | 对dart 日期API的扩展，新增功能API参考 [date API](#date)   |
| `fun`          | 全局函数，包括对硬件的发送指令，API参考 [fun API](#fun)   |
| `udp`          | udp 客户端的封装                                          |
| `my_switch`    | 自定义开关小部件                                          |
| `radar`        | 自定义雷达扫码小部件                                      |
 
 
#### <a id = "config">config配置</a>
| 配置项         | 描述         |
| -------------- | ------------ |
| `COAP_API_URL` | coap服务地址 |
| `COAP_PORT`    | coap服务端口 |
| `UDP_PORT`     | udp端口      |
#### <a id = "ble">ble API</a>
| 方法                           | 描述                                                       |
| ------------------------------ | ---------------------------------------------------------- |
| `status`                       | 获取蓝牙的状态,如果都正常则开始扫描,不正常则去跳出弹窗提示 |
| `scan`                         | 扫描蓝牙设备                                               |
| `stopScan`                     | 停止扫描                                                   |
| `onScanResults`                | 监听扫描到的设备内容和实时扫描结果流                       |
| `scanResults`                  | 监听实时扫描结果                                           |
| `lastScanResults`              | 最后的扫描结果                                             |
| `onScanResultsByAdvertisement` | 监听蓝牙广播内容                                           |
| `connect`                      | 连接设备                                                   |
| `disconnect`                   | 断开连接                                                   |
| `isConnect`                    | 设备是否连接                                               |
| `getUUID`                      | 获取所有的的服务列表                                       |
| `writeWithOut`                 | 无返回写数据                                               |
#### <a id = "CoAP">CoAP API</a>
| 方法                | 描述                             |
| ------------------- | -------------------------------- |
| `get`               | 发送GET请求                      |
| `post`              | 发送POST请求，载荷是字符         |
| `postBytes`         | 发送POST请求，载荷是字节         |
| `put`               | 发送PUT请求                      |
| `sendRPC`           | 向硬件发送rpc请求                |
| `sendTranCoapByStr` | 向硬件发送透传数据，载荷字符串   |
| `sendTranCoap`      | 向硬件发送透传数据，载荷字节数组 |
 
#### <a id = "common">Common API</a>
| 方法                 | 描述               |
| -------------------- | ------------------ |
| `isIpad`             | 判断是否为ipad     |
| `getScreenWidth`     | 获取当前组件的宽度 |
| `getScreenHeight`    | 获取屏幕的高度     |
| `isHorizontalScreen` | 判断设备是否横屏   |

#### <a id = "date">Date 扩展API</a>
| 方法          | 描述                           |
| ------------- | ------------------------------ |
| `isToday`     | 是否为今天                     |
| `isTomorrow`  | 是否为明天                     |
| `isYesterday` | 是否为昨天                     |
| `isThisWeek`  | 判断日期是否属于现在时间的星期 |
| `isThisMonth` | 判断日期是否属于现在时间的月份 |
 
 
#### <a id = "fun">全局函数</a>
| 方法                | 描述                   |
| ------------------- | ---------------------- |
| `sendWifi`          | 使用wifi向设备发送数据 |
| `sendCoapData`      | 使用Coap向设备发送数据 |
| `isWifi`            | 判断当前wifi是否连接   |
| `versionComparison` | 比较版本号             |
 
#### <a id = "esp32">esp32 蓝牙处理功能</a>
| 方法                        | 描述                        |
| --------------------------- | --------------------------- |
| `sendData`                  | 向ESP32设备发送数据         |
| `handleDataByAdvertisement` | 处理 ESP32设备 蓝牙广播数据 |
 
  


## 使用

### 使用蓝牙
使用蓝牙工具与硬件交互
```dart
    import 'package:ict_all/ble/ble.dart';
  
  
  //蓝牙
  late Ble ble1;
  //蓝牙连接状态
  String bleStatus = '未连接';
  bool scaning = false; //正在扫描中
  List<ScanResult> devices = []; //扫描到的设备
  //搜到设备监听
  StreamSubscription? _sacnSubscription;
  //连接状态监听
  StreamSubscription? _connectionSubscription;

  StreamSubscription? _isScaning;
  BluetoothConnectionState connectStatus =
      BluetoothConnectionState.disconnected;
  bool isConnected = false; //已经连接成功
 
 
 void initState() {
   //蓝牙初始化
    ble1 = Ble.instance;
     ble1.onScanResults(callbackLast: (event) {
  print(
          "搜索到的---设备列表:${event.device.name}----${event.advertisementData.localName}");

     });

     _connectionSubscription?.cancel();

      _connectionSubscription = ble1.connectController.stream.listen((event) {

          setState(() {
            connectStatus = event;
            switch (event) {
              case BluetoothConnectionState.connected:
                isConnected = true;
                break;
              case BluetoothConnectionState.disconnected:
                Timer(const Duration(milliseconds: 400), () {
                  if (connectStatus == BluetoothConnectionState.disconnected) {
                    //400毫秒后还是未连接才代表断开了连接
                    isConnected = false;
                  }
                });

                break;
              default:
            }
          });

      });
         _sacnSubscription?.cancel();
  ble1.isScaning((event) {

           setState(() {
          scaning = event;
        });
  });

  ble1.status(timeout: const Duration(seconds: 8));
 }
```

### 使用CoAP
使用CoAP与硬件交互
```dart
import 'package:ict_all/coap/coap_client.dart';

  CoapClientUtil coapClient = CoapClientUtil();
    var res = await coapClient.get(
      '/hello',
      accept: CoapMediaType.applicationJson,
    );
 print("返回结果是:${res!.payloadString}");

```

### 使用UDP
使用udp与硬件交互
```dart
import 'package:ict_all/utils/udp.dart';

     //udp获取到的数据
     StreamSubscription? _sacnSubscription;
     UDPClient udpClient = UDPClient.instance;
    _sacnSubscription?.cancel();
    _sacnSubscription = udpClient.getDataController.stream.listen((data) {
      if (data is List<int>) {
        print("接收数据:$data");
        if (data[0] == 170 && data.length == 15 && data[14] == 85) {
          //将从data[7]开始截取数组
          List macArr = data.sublist(7, 13); //截取mac地址
          //将十进制数组转换成十六进制mac并添加:
          String macStr =
              macArr.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');
          print("macArr:$macArr -----${macStr}");

          setState(() {
            serverIp = "${data[3]}.${data[4]}.${data[5]}.${data[6]}";
            print("获取到了ip地址:$serverIp");
          });
        }
      }
    });
```
