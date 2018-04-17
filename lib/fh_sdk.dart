import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class FhSdk {
  static String _alias;
  static List<String> _categories;

  static const MethodChannel _channel = const MethodChannel('fh_sdk');

  // This method initializes the FH SDK
  static Future<String> init () => _channel.invokeMethod('init');

  // This function returns the actual Cloud App URL associated with the connection tag
  static Future<String> getCloudUrl () => _channel.invokeMethod('getCloudUrl');

  // This function invokes a REST endpoint exposed in the Cloud App. Receives a Map of options: path, data, etc.
  // Returns either a String if raw === true or a List (if Array) or Map (if JSON object) otherwise
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

  // This function invokes an authentication policy given the policy name, username and password.
  // Returns either a String if raw === true or a List (if Array) or Map (if JSON object) otherwise
  static Future<dynamic> auth (String authPolicy, String username, String password, [bool raw = false]) { 
    Completer completer = new Completer();
    _channel.invokeMethod('auth', {'authPolicy': authPolicy, 'username': username, 'password': password}).then((stringData) {
      if (raw) {
        completer.complete(stringData);
      } else {
        completer.complete(JSON.decode(stringData));
      }
    });

    return completer.future;
  }

  // Alias and Categories setters/getters
  static set alias (String alias) => _alias = alias;
  static get alias  => _alias;
  static set categories (List<String> categories) => _categories = categories;
  static get categories  => _categories;

  // This method registers the client in the corresponding Push Notification server
  static Future<String> pushRegister ([bool raw = false]) {
    Completer completer = new Completer();
    _channel.invokeMethod('pushRegister').then((stringData) {
      if (raw) {
        completer.complete(stringData);
      } else {
        completer.complete(JSON.decode(stringData));
      }
    });

    return completer.future;
  }

  // This method registers the client in the corresponding Push Notification server providing alias and categories
  static Future<String> pushRegisterWithAliasAndCategories (String alias, List<String> categories) => _channel.invokeMethod('pushRegister', {'alias': alias, 'categories': categories});

  // This method registers the client in the corresponding Push Notification server providing alias and categories
  static Future<String> pushRegisterWithAliasAndCategoriesOld (String alias, List<String> categories, [bool raw = false]) {
    Completer completer = new Completer();
    _channel.invokeMethod('pushRegister', {'alias': alias, 'categories': categories}).then((stringData) {
      if (raw) {
        completer.complete(stringData);
      } else {
        completer.complete(JSON.decode(stringData));
      }
    });

    return completer.future;
  }
}
