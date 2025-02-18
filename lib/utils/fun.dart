import 'package:connectivity_plus/connectivity_plus.dart';

add0Of2(String item) {
  int length = item.length;
  if (length < 8) {
    int chazhi = 8 - length;
    String str = '';
    for (int i = 0; i < chazhi; i++) {
      str += '0';
    }
    return '$str$item';
  }
  return item;
}

//从得到的数据里获得一组正确的数据
List<List<int>> setNewArr(
  List<int> arr,
) {
  //把所有的正确数据都放在newArr中（可能多组包）

  //这里做了断包与连包的处理  receive_data_buffer

  List<int> receiveDataBuffer = arr;
  int j = 0, num = 0;
  List<int> newArr = [];
  List<List<int>> trueArr = [];
  int lastFlog = 0; //获取符合协议的数组最后一位所在的索引. 最后讲0到索引的数据删除
  for (int i = 0; i < receiveDataBuffer.length;) {
    // console.log(i, receive_data_buffer, receive_data_buffer.length);
    //找到一组数据的头部
    if (receiveDataBuffer[i] == 170) {
      j = i;
      int dataLength = receiveDataBuffer[j + 1]; //数据为的数值
      // print(
      //   'dataLength:$dataLength',
      // );
      //根据数据位长度找到数据尾部
      if (dataLength + i + 1 < receiveDataBuffer.length &&
          receiveDataBuffer[dataLength + i + 1] == 85) {
        // print("${i}的头尾满足");
        for (; j <= dataLength + 1 + i; j++) {
          //这里+i是为了防止连包的问题,不加就只在第一组徘徊
          //把找到的数据赋值给newArr
          newArr.add(receiveDataBuffer[j]);
          lastFlog = j;
        }
        //做效验处理,如果效验成功了则把这组数据传给trueArr,失败则清空这组数据
        if (check(newArr) == newArr[newArr.length - 2]) {
          // print("${i}的校验满足");
          i = dataLength + 1 + i;
          num = i;
          trueArr.add(newArr);
          newArr = [];
        } else {
          i++;
          newArr = [];
          lastFlog = 0;
        }
      } else {
        i++;
      }
    } else {
      i++;
    }
  }
  // if (fenduan != null) {
  //   fenduan.removeRange(0, lastFlog);
  // }
  // print("lastFlog:$lastFlog------${arr.length}");
  if (lastFlog > arr.length) {
    arr.clear();
  } else {
    try {
      arr.removeRange(0, lastFlog);
    } catch (e) {}
  }

  return trueArr;
}

//校验函数
int check(List<int> arr) {
  if (arr.length < 3) {
    return -1;
  }
  int checkFloag = arr[1];

  for (int i = 2; i < arr.length - 2; i++) {
    checkFloag = checkFloag ^ arr[i];
  }
  return checkFloag;
}

// 发送数据
List<int> sendWifi(
  String command,
  List<String> arr,
) {
  //帧长,如果帧长是一位,前面加0
  int length = arr.length + 3;

  //开始生成校验位
  int check = (length ^ int.parse(command, radix: 16));
  List<int> list = [170, length, int.parse(command, radix: 16)];
  for (var i = 0; i < arr.length; i++) {
    check = check ^ int.parse(arr[i], radix: 16);
    list.add(int.parse(arr[i], radix: 16));
  }
  //如果校验位长度为1前面补0

  list.addAll([check, 85]);
  return list;
}

// 发送数据
List<int> sendData(
  String command,
  List<String> arr,
  String esp32command,
  int sequence,
) {
  //帧长,如果帧长是一位,前面加0
  int length = arr.length + 3;

  //开始生成校验位
  int check = (length ^ int.parse(command, radix: 16));
  List<int> list = [170, length, int.parse(command, radix: 16)];
  for (var i = 0; i < arr.length; i++) {
    check = check ^ int.parse(arr[i], radix: 16);
    list.add(int.parse(arr[i], radix: 16));
  }
  //如果校验位长度为1前面补0

  list.addAll([check, 85]);
  return sendDataESP32(esp32command, list, sequence);
}

//command,ESP32的控制命令,必须是4个字节
List<int> sendDataESP32(String command, List<int> arr, int sequence) {
  List<int> sendArr = [];
  //帧长,如果帧长是一位,前面加0
  command = add0ToDataLength(command, 4);
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

  int arrLength = arr.length;

  sendArr = commandArr + [sequence] + [arrLength] + arr;
  List<String> dataArr = [];
  // for (var i = 0; i < sendArr.length; i++) {
  //   var element = sendArr[i];
  //   String str = element.toRadixString(16);
  //   str = str.length == 1 ? "0$str" : str;
  //   dataArr.add(str);
  // }

  return sendArr;
  // print('发送的数据:$sendArr');
  // print('发送的数据16:$dataArr');

  // Timer(Duration(milliseconds: 50), () {
  //   print("发送的数据:$sendArr");
  //   ble1.writeWithOut(sendArr);
  // });
}

add0ToDataLength(value, length) {
  while (value.length < length) {
    // ignore: prefer_interpolation_to_compose_strings
    value = '0' + value;
  }
  return value;
}

String dateTimeToHourAndMinute(DateTime dateTime) {
  String upTimeH = "${dateTime.hour}";
  String upTimeM = "${dateTime.minute}";
  if (upTimeH.length < 2) {
    upTimeH = "0$upTimeH";
  }
  if (upTimeM.length < 2) {
    upTimeM = "0$upTimeM";
  }
  //开机时间
  String startTime = "$upTimeH:$upTimeM";

  return startTime;
}

Future<bool> isWifi() async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult == ConnectivityResult.wifi;
}

List<int> sendCoapData(String command, List<int> arr) {
  List<int> sendArr = [];
  int length = arr.length + 3;
  //开始生成校验位
  int check = length ^ int.parse(command, radix: 16);
  sendArr.addAll([170, length, int.parse(command, radix: 16)]);
  for (int i = 0; i < arr.length; i++) {
    check = check ^ arr[i];
    sendArr.add(arr[i]);
  }
  sendArr.addAll([check, 85]);

  return sendArr;
}

//判断第一个参数的版本是否大于第二个参数
bool versionComparison(String version1, String version2) {
  List<String> version1Arr = version1.split('.');
  List<String> version2Arr = version2.split('.');

  int num(String param) {
    return int.parse(param);
  }

  if (num(version1Arr[0]) >= num(version2Arr[0]) &&
      num(version1Arr[1]) >= num(version2Arr[1]) &&
      num(version1Arr[2]) > num(version2Arr[2])) {
    return true;
  } else {
    return false;
  }
}
