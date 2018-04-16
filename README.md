# fh_sdk

Unofficial flutter plugin for [Red Hat Mobile](https://access.redhat.com/documentation/en-us/red_hat_mobile_application_platform_hosted/). This plugin uses both Android and iOS Red Hat Mobile SDK, you can find further information [here]()https://access.redhat.com/documentation/en-us/red_hat_mobile_application_platform_hosted/3/html/client_sdk/.

# Usage

Prior to importing the plugin make sure your configuration files for Android and iOS are placed in the default location for each platform. As part of this plugin we provide an example project already set up with a dummy configuration file.

## Importing the plugin

Import `package:fh_sdk/fh_sdk.dart`, instantiate `FH` and invoke one of the supported operations as in the following example. Take into account that you have to initialize the plugin before invoking any other operation.

Example of initialization:

```dart
import 'package:fh_sdk/fh_sdk.dart';

String result;
String message = 'Init call running';

try {
    result = await FhSdk.init();
    print('initResult' + result);
    message = result.toString();
} on PlatformException catch (e) {
    message = 'Error in FH Init $e';
}
```

You will find links to the API docs on the [pub page](https://pub.dartlang.org/packages/fh_sdk).

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).