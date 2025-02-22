// GENERATED CODE, do not edit this file.

import 'package:coap/coap.dart';

///配置加载类。配置文件本身是一个YAML
///文件下面的配置项标记为可选，以允许
///配置文件只包含那些覆盖默认值的条目。
///文件不能为空，因此必须至少存在版本。
class CoapConfig extends DefaultCoapConfig {
  @override
  int get defaultPort => 5683;

  @override
  int get defaultSecurePort => 5684;

  @override
  int get httpPort => 8080;

  @override
  int get ackTimeout => 3000;

  @override
  double get ackRandomFactor => 1.5;

  @override
  double get ackTimeoutScale => 2.0;

  @override
  int get maxRetransmit => 8;

  @override
  int get maxMessageSize => 1024;

  @override
  int get preferredBlockSize => 512;

  @override
  int get blockwiseStatusLifetime => 60000;

  @override
  bool get useRandomIDStart => true;

  @override
  int get notificationMaxAge => 128000;

  @override
  int get notificationCheckIntervalTime => 86400000;

  @override
  int get notificationCheckIntervalCount => 100;

  @override
  int get notificationReregistrationBackoff => 2000;

  @override
  int get cropRotationPeriod => 2000;

  @override
  int get exchangeLifetime => 1247000;

  @override
  int get markAndSweepInterval => 10000;

  @override
  int get channelReceivePacketSize => 2048;

  @override
  String get deduplicator => 'MarkAndSweep';
}
