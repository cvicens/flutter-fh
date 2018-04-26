import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

typedef void NotificationHandler(MethodCall call);

class FhSdk {
  static const MethodChannel _channel = const MethodChannel('fh_sdk');

  /// This method initializes this plugin.
  /// Call this once before any further interaction with the the plugin.
  static void initialize(NotificationHandler notificationHandler) {
    _channel.setMethodCallHandler((MethodCall call) {
      assert(call != null && call.method != null);
      notificationHandler(call);
    });
  }

  /// This method initializes the FH SDK
  static Future<String> init () async { 
    final String result = await _channel.invokeMethod('init');
    return result;
  }

  /// This function returns the actual Cloud App URL associated with the connection tag
  static Future<String> getCloudUrl () async { 
    final String result = await _channel.invokeMethod('getCloudUrl');
    return result;
  }

  /// This function invokes a REST endpoint exposed in the Cloud App. Receives a Map of options: path, data, etc.
  /// Returns either a String if raw === true or a List (if Array) or Map (if JSON object) otherwise
  static Future<dynamic> cloud (Map<String, dynamic> options, [bool raw = false]) async {
    assert(options != null);

    if (options['method'] == null || options['path'] == null) {
      throw new ArgumentError.value(options, 'path, method can\'t be null');
    }

    dynamic result = await _channel.invokeMethod('cloud', options);
    if (raw) {
      return result;
    }
    
    return json.decode(result);
  }

  /// This function invokes an authentication policy given the policy name, username and password.
  /// Returns either a String if raw === true or a List (if Array) or Map (if JSON object) otherwise
  static Future<dynamic> auth (String authPolicy, String username, String password, [bool raw = false]) async {
     assert(authPolicy != null && username != null && password != null);
    
    if (authPolicy.length <= 0) {
      throw new ArgumentError.value(authPolicy, 'authPolicy, method can\'t be empty');
    }

    if (username.length <= 0) {
      throw new ArgumentError.value(username, 'username, method can\'t be empty');
    }

    dynamic result = await _channel.invokeMethod('auth', {'authPolicy': authPolicy, 'username': username, 'password': password});
    if (raw) {
      return result;
    }
    
    return json.decode(result);
  }

  /// This method registers the client in Red Hat Mobile push notifications server
  static Future<String> pushRegister ([bool raw = false]) {
    Completer completer = new Completer();
    _channel.invokeMethod('pushRegister').then((stringData) {
      if (raw) {
        completer.complete(stringData);
      } else {
        completer.complete(json.decode(stringData));
      }
    });

    return completer.future;
  }

  /// This method registers the client in the corresponding Push Notification server providing alias and categories
  static Future<String> pushRegisterWithAliasAndCategories (String alias, List<String> categories) async {
    String result = await _channel.invokeMethod('pushRegister', {'alias': alias, 'categories': categories});
    return result;
  }
  
  /// This method set the alias used for push notifications
  static Future<String> setPushAlias (String alias)  async {
    String result = await _channel.invokeMethod('setPushAlias', {'alias': alias});
    return result;
  }
  

  /// This method set the categories used for push notifications
  static Future<String> setPushCategories (List<String> categories)  async {
    String result = await _channel.invokeMethod('setPushCategories', {'categories': categories});
    return result;
  }
}
