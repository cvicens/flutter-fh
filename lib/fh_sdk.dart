import 'dart:async';

import 'package:flutter/services.dart';

class FhSdk {
  static const MethodChannel _channel =
      const MethodChannel('fh_sdk');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');

  static Future<List> init () =>
      _channel.invokeMethod('init');
}
