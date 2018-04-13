import 'dart:async';

import 'package:flutter/services.dart';

class FhSdk {
  static const MethodChannel _channel = const MethodChannel('fh_sdk');

  static Future<String> get platformVersion => _channel.invokeMethod('getPlatformVersion');

  static Future<String> init () => _channel.invokeMethod('init');

  static Future<Map> cloud (Map<String, String> options) => _channel.invokeMethod('cloud', options);

  static Future<Map> auth (String authPolicy, String username, String password) => _channel.invokeMethod('auth', {'authPolicy': authPolicy, 'username': username, 'password': password});

  static Future<String> getClourUrl () => _channel.invokeMethod('getCloudUrl');
}
