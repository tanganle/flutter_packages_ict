import 'dart:async';
import 'package:coap/coap.dart';
import 'package:ict_all/coap/coap_config.dart';
import 'package:ict_all/config/config.dart';

import 'package:typed_data/typed_data.dart';

class CoapClientUtil {
  factory CoapClientUtil({String? host, int? port}) =>
      _getInstance(host: host, port: port);
  static CoapClientUtil get instance => _getInstance(host: _currentHost);
  static CoapClientUtil? _instance;
  static CoapClient? client;
  static String _currentHost = Config.instance.COAP_API_URL;
  static int _currentPort = Config.instance.COAP_PORT;

  static CoapClientUtil _getInstance({String? host, int? port}) {
    String localHost = host ?? Config.instance.COAP_API_URL;
    int localPort = port ?? Config.instance.COAP_PORT;
    if (_instance == null ||
        _currentHost != localHost ||
        _currentPort != localPort) {
      _instance = CoapClientUtil._internal(localHost, localPort);
      _currentHost = localHost;
      _currentPort = localPort;
    }
    return _instance!;
  }

  CoapClientUtil._internal(String host, int port) {
    CoapConfig conf = CoapConfig();
    var baseUri = Uri(scheme: 'coap', host: host, port: port);
    client = CoapClient(baseUri, config: conf);
  }

  // 发送GET请求
  Future<CoapResponse?> get(
    final String path, {
    final CoapMediaType? accept,
    final bool confirmable = true,
    final List<Option<Object?>>? options,
    final bool earlyBlock2Negotiation = false,
    final int maxRetransmit = 0,
    final CoapMulticastResponseHandler? onMulticastResponse,
  }) async {
    try {
      var response = await client!.get(
        Uri(path: path),
        accept: accept,
        confirmable: confirmable,
        options: options,
        earlyBlock2Negotiation: earlyBlock2Negotiation,
        maxRetransmit: maxRetransmit,
        onMulticastResponse: onMulticastResponse,
      );
      return response;
    } catch (e) {
      print("错误的内容:${e}");
      return null;
    }
  }

  // 发送POST请求
  Future<CoapResponse?> post(
    final String path, {
    required final String payload,
    final CoapMediaType? format,
    final CoapMediaType? accept,
    final bool confirmable = true,
    final List<Option<Object?>>? options,
    final bool earlyBlock2Negotiation = false,
    final int maxRetransmit = 0,
    final CoapMulticastResponseHandler? onMulticastResponse,
  }) async {
    try {
      var response = await client!.post(
        Uri(path: path),
        payload: payload,
        format: format,
        accept: accept,
        confirmable: confirmable,
        options: options,
        earlyBlock2Negotiation: earlyBlock2Negotiation,
        maxRetransmit: maxRetransmit,
        onMulticastResponse: onMulticastResponse,
      );
      return response;
    } catch (e) {
      print("错误的内容:${e}");
      return null;
    }
  }

  /// 发送post请求,且携带的参数为二进制数组
  /// 需要注意的是如果返回的数据也是二进制数组则打印的response中的Payload为<<<< Payload incomplete >>>>>
  //// 这是因为展示的payload走的是res.payloadString,看下发源码可知,转换成utf8抛出异常了,我们只要拿数据的时候使用res.payload即可
  /// String get payloadString {
  ///   final payload = this.payload;
  ///   if (payload.isNotEmpty) {
  ///     try {
  ///       final ret = utf8.decode(payload);
  ///       return ret;
  ///     } on FormatException catch (_) {
  ///       // The payload may be incomplete, if so and the conversion
  ///       // fails indicate this.
  ///       return '<<<< Payload incomplete >>>>>';
  ///     }
  ///   }
  ///   return '';
  /// }

  Future<CoapResponse?> postBytes(
    final String path, {
    required final Uint8Buffer payload,
    final CoapMediaType? format,
    final CoapMediaType? accept,
    final bool confirmable = true,
    final List<Option<Object?>>? options,
    final bool earlyBlock2Negotiation = false,
    final int maxRetransmit = 0,
    final CoapMulticastResponseHandler? onMulticastResponse,
  }) async {
    try {
      var response = await client!.postBytes(
        Uri(path: path),
        payload: payload,
        format: format,
        accept: accept,
        confirmable: confirmable,
        options: options,
        earlyBlock2Negotiation: earlyBlock2Negotiation,
        maxRetransmit: maxRetransmit,
        onMulticastResponse: onMulticastResponse,
      );
      return response;
    } catch (e) {
      print("错误的内容:${e}");
      return null;
    }
  }

  // 发送PUT请求
  Future<CoapResponse?> put(
    final String path, {
    required final String payload,
    final CoapMediaType? format,
    final CoapMediaType? accept,
    final bool confirmable = true,
    // final List<Uint8Buffer>? etags,
    final MatchEtags matchEtags = MatchEtags.onMatch,
    final List<Option<Object?>>? options,
    final bool earlyBlock2Negotiation = false,
    final int maxRetransmit = 0,
    final CoapMulticastResponseHandler? onMulticastResponse,
  }) async {
    try {
      var response = await client!.put(
        Uri(path: path),
        payload: payload,
        format: format,
        accept: accept,
        confirmable: confirmable,
        // etags: etags,
        matchEtags: matchEtags,
        options: options,
        earlyBlock2Negotiation: earlyBlock2Negotiation,
        maxRetransmit: maxRetransmit,
        onMulticastResponse: onMulticastResponse,
      );
      return response;
    } catch (e) {
      print("错误的内容:${e}");
      return null;
    }
  }

  close() {
    client?.close();
  }

  disply() {
    client?.close();
    client = null;
    _instance = null;
  }

  //发送rpc请求
  Future<CoapResponse?> sendRPC(String mac, String payload) async {
    // String macStr = '11:22:33:44:55:66';
    var res = await post('/api/v1/$mac/rpc',
        accept: CoapMediaType.applicationJson, payload: payload);
    return res;
  }

  //发送透传数据 载荷字符串
  Future<CoapResponse?> sendTranCoapByStr(String mac, String payload) async {
    // String macStr = '11:22:33:44:55:66';
    var res = await post('/api/v1/$mac/trans',
        accept: CoapMediaType.applicationJson, payload: payload);
    return res;
  }

  //发送透传数据 载荷字节数组
  Future<CoapResponse?> sendTranCoap(String mac, Uint8Buffer payload) async {
    // String macStr = '11:22:33:44:55:66';
    var res = await postBytes('/api/v1/$mac/trans',
        accept: CoapMediaType.applicationJson, payload: payload);
    return res;
  }
}
