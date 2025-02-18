import 'package:flutter/material.dart';

class SystemCommon {
  //判断是否为ipad
  bool isIpad() {
    MediaQueryData data =
        MediaQueryData.fromView(WidgetsBinding.instance.window);
    return data.size.shortestSide >= 600;
  }

  //获取当前组件的宽度
  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  //获取屏幕的高度
  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  //判断设备是否横屏
  bool isHorizontalScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height;
  }
}
