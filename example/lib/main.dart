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

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    List initResult;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FhSdk.platformVersion;
      print('platformVersion' + platformVersion);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      initResult = await FhSdk.init();
      print('initResult' + initResult.toString());
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _platformVersion = platformVersion;
      _initResult = initResult.toString();
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
                  new FlatButton(
                    child: const Text('BUTTON TITLE'),
                    onPressed: () {
                      // Perform some action
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
