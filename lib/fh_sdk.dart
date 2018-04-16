import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class FhSdk {
  static const MethodChannel _channel = const MethodChannel('fh_sdk');

  static Future<String> get platformVersion => _channel.invokeMethod('getPlatformVersion');

  static Future<String> init () => _channel.invokeMethod('init');

  // This function returns either a String if raw === true or a List (if Array) or Map (if JSON object) otherwise
  static Future<dynamic> cloud (Map<String, String> options, [bool raw = false]) {
    Completer completer = new Completer();
    _channel.invokeMethod('cloud', options).then((stringData) {
      if (raw) {
        completer.complete(stringData);
      } else {
        completer.complete(JSON.decode(stringData));
      }
    });

    return completer.future;
  }

  static Future<Map> auth (String authPolicy, String username, String password) => _channel.invokeMethod('auth', {'authPolicy': authPolicy, 'username': username, 'password': password});

  static Future<String> getClourUrl () => _channel.invokeMethod('getCloudUrl');
}
