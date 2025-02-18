class Config {
  static Config? _instance;

  //coap的地址
  String COAP_API_URL = '192.168.0.63';
  int COAP_PORT = 5683;
  //udp的端口号
  int UDP_PORT = 1234;

  static Config get instance {
    if (_instance == null) {
      _instance = Config._init();
    }
    return _instance!;
  }

  Config._init();
}
