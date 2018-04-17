import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fh_sdk/fh_sdk.dart';

void main() => runApp(new MyApp());

class TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(32.0),
      child: new Row(
        children: [
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                new Text('This is just and example Flutter app using the hello endpoint. Please, type something (your name for instance) and hit the button',
                  style: new TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _fhInit = false;
  String _messages = 'No messages';

  @override
  initState() {
    super.initState();
    initFHState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initFHState() async {
    String result;
    String message = 'Init call running';

    try {
      result = await FhSdk.init();
      print('initResult' + result);
      message = result.toString();
    } on PlatformException catch (e) {
      message = 'Error in FH Init $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _fhInit = result != null && result.contains('SUCCESS') ? true : false;
      _messages = message;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  getCloudUrl() async {
    String result;
    String message;

    try {
      result = await FhSdk.getCloudUrl();
      print('cloudHost' + result);
      message = result.toString();
    } on PlatformException catch (e) {
      message = 'Error in FH getCloudUrl $e';
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

  // Platform messages are asynchronous, so we initialize in an async method.
  sayHello(String name) async {
    dynamic data;
    String message;

    String hello = (name == null || name.length <=0) ? 'world' : name;

    try {
      Map options = {
        "path": "/hello?hello=" + hello.replaceAll(' ', ''),
        "method": "GET",
        "contentType": "application/json",
        "timeout": 25000 // timeout value specified in milliseconds. Default: 60000 (60s)
      };
      data = await FhSdk.cloud(options);
      print('data ==> ' + data.toString());
      message = data.toString();
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
    dynamic data;
    String message;

    try {
      data = await FhSdk.auth(authPolicy, username, password);
      message = data['message'];
      print('auth data' + data['message']);
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
  pushRegister(String alias, List<String> categories) async {
    dynamic data;
    String message;

    try {
      data = await FhSdk.pushRegisterWithAliasAndCategories(alias, categories);
      message = data.toString();
      print('pushRegister data' + data.toString());
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
    final TextEditingController _controller = new TextEditingController();
    TitleSection titleSection = new TitleSection();
    Container formSection = new Container(
      padding: const EdgeInsets.all(28.0),
      child: new Row(
        children: [
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //new TitleSection(),
                new ListTile(
                  leading: const Icon(Icons.person),
                  title: new TextField(
                    controller: _controller,
                    decoration: new InputDecoration(
                      hintText: "Name",
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Red Hat MAP - Hello Test'),
        ),
        body: new ListView(
          children: [ 
            titleSection,
            formSection,
            const Divider(
              height: 1.0,
            ),
            new Container(
              padding: const EdgeInsets.all(32.0),
              child: new RaisedButton(
                child: new Text(_fhInit ? 'Say Hello' : 'Init in progress...'),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: !_fhInit ? null : () {
                  // Perform some action
                  sayHello(_controller.text);
                }
              )
            ),
             new Container(
              padding: const EdgeInsets.all(32.0),
              child: new RaisedButton(
                child: new Text(_fhInit ? 'Test auth' : 'Init in progress...'),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: !_fhInit ? null : () {
                  // Perform some action
                  auth('popagame', 'trever', '123');
                  getCloudUrl();
                }
              )
            ),
            new Container(
              padding: const EdgeInsets.all(32.0),
              child: new RaisedButton(
                child: new Text(_fhInit ? 'Register for push notifications' : 'Init in progress...'),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: !_fhInit ? null : () {
                  // Perform some action
                  pushRegister('trever', ['driver', 'employee']);
                }
              )
            ),
            new Container(
              padding: const EdgeInsets.all(32.0),
              child: new Card(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new ListTile(
                      //leading: const Icon(Icons.album),
                      title: const Text('Messages'),
                      subtitle: new Text('$_messages'),
                    )                    
                  ],
                ),
              )
            )
          ]
        ),
      ),
    );
  }
}
