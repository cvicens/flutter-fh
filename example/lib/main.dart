import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fh_sdk/fh_sdk.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _initResult = 'Unknown';
  String _messages = 'No messages';

  @override
  initState() {
    super.initState();
    initPlatformState();
    initFHState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    String message;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FhSdk.platformVersion;
      print('platformVersion' + platformVersion);
    } on PlatformException {
      message = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _platformVersion = platformVersion;
      _messages = message;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initFHState() async {
    String result;
    String message;

    try {
      result = await FhSdk.init();
      print('initResult' + result);
    } on PlatformException catch (e) {
      message = 'Error in FH Init $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _initResult = result.toString();
      _messages = message;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  sayHello(String name) async {
    Map data;
    String message;

    try {
      Map options = {
        "path": "/hello?world=" + name,
        "method": "GET",
        "contentType": "application/json",
        "timeout": 25000 // timeout value specified in milliseconds. Default: 60000 (60s)
      };
      data = await FhSdk.cloud(options);
      message = data.toString();
      print('data' + data.toString());
    } on PlatformException catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
      message = 'Error calling hello';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _messages = message;
    });
  }

// Authentication test
  auth(String authPolicy, String username, String password) async {
    Map data;
    String message;

    try {
     
      data = await FhSdk.auth(authPolicy, username, password);
      message = data['message'];
      print('data' + data['message']);
    } on PlatformException catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
      message = 'Error calling hello';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _messages = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Row(
            children: [
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  new Text('Running on: $_platformVersion'),
                  new Text('FH init result: $_initResult'),
                  new Text('Messages $_messages'),
                  new FlatButton(
                    child: const Text('Say Hello'),
                    onPressed: () {
                      // Perform some action
                      sayHello('Carlos');
                    }
                  ),
                  new FlatButton(
                    child: const Text('Authenticate'),
                    onPressed: () {
                      // Perform some action
                      auth('popagame', 'trever', '123');
                    }
                  )
                ]
              ),
            ]
          )
        ),
      ),
    );
  }
}
