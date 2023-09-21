import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';


import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_toast/m_toast.dart';
import 'package:msg_poc/MessageService.dart';
import 'dart:async';

import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

import 'message.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// @pragma('vm:entry-point')
// void handleBackgroundNotifications(FirebaseApp _app) {
//   print("Inside handleBackgroundNotifications");
//   FirebaseDatabase db = FirebaseDatabase(
//       app: _app,
//       databaseURL: 'https://fir-msg-database-default-rtdb.firebaseio.com/');
//   db.goOnline();
//   final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   final _winNotifyPlugin = WindowsNotification(applicationId: "Test Application"
//       // r"{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}\WindowsPowerShell\v1.0\powershell.exe"
//       );
//   _winNotifyPlugin.initNotificationCallBack((notification, status, argruments) {
//     print("aargs: $argruments");
//   });
//   db.reference().onValue.listen((event) async {
//     final data = event.snapshot.value;
//     print(data);
//     // print(data['message']);
//     // final res = data['message'];
//     if (res != null && res['title'] != null) {
//       Message message = Message.fromMap(res);
//       print("MEssage :: $message");
//       if (message.device == (await deviceInfo.windowsInfo).computerName ||
//           message.device == null) {
//         NotificationMessage _message = NotificationMessage.fromPluginTemplate(
//           "#001",
//           message.title,
//           message.subtitle ?? "",
//         );
//         ShowMToast toast = ShowMToast();
//         _winNotifyPlugin.showNotificationPluginTemplate(_message);
//       }
//     }
//   });
//
//   print("COmpleted");
// }

void main() async {
  // For full-screen example
  // WidgetsFlutterBinding.ensureInitialized();
  // await windowManager.ensureInitialized();
  //
  // runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1920, 1080),
    center: true,
    backgroundColor: Colors.black,
    skipTaskbar: false,
    title: "Mobex Health Hub",
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  FirebaseDart.setup();
  var app = await Firebase.initializeApp(
      options: FirebaseOptions.fromMap(
          json.decode(File('lib/firebase-config.json').readAsStringSync())));
  // handleBackgroundNotifications(app);
  // runApp(MediaQuery(data: MediaQueryData., child: ScaffoldMessenger(child: MessageService( app: app,))));
  //   runApp(MaterialApp(home: Scaffold(body: Center(child: MaterialApp(home: MessageService(app: app)),),),));
  // runApp(MyApp());
  runApp(MessageService(app: app));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(navigatorKey: navigatorKey, home: ExampleBrowser());
  }
}

class ExampleBrowser extends StatefulWidget {
  @override
  State<ExampleBrowser> createState() => _ExampleBrowser();
}

class _ExampleBrowser extends State<ExampleBrowser> {
  final _controller = WebviewController();
  final _textController = TextEditingController();
  final List<StreamSubscription> _subscriptions = [];
  bool _isWebviewSuspended = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    try {
      await _controller.initialize();
      _subscriptions.add(_controller.url.listen((url) {
        _textController.text = url;
      }));

      _subscriptions
          .add(_controller.containsFullScreenElementChanged.listen((flag) {
        debugPrint('Contains fullscreen element: $flag');
        windowManager.setFullScreen(flag);
      }));

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl('https://flutter.dev');

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  Widget compositeView() {
    if (!_controller.value.isInitialized) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // MessageService(app: app);
            // Card(
            //   elevation: 0,
            //   child: Row(children: [
            //     Expanded(
            //       child: TextField(
            //         decoration: InputDecoration(
            //           hintText: 'URL',
            //           contentPadding: EdgeInsets.all(10.0),
            //         ),
            //         textAlignVertical: TextAlignVertical.center,
            //         controller: _textController,
            //         onSubmitted: (val) {
            //           _controller.loadUrl(val);
            //         },
            //       ),
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.refresh),
            //       splashRadius: 20,
            //       onPressed: () {
            //         _controller.reload();
            //       },
            //     ),
            //     IconButton(
            //       icon: Icon(Icons.developer_mode),
            //       tooltip: 'Open DevTools',
            //       splashRadius: 20,
            //       onPressed: () {
            //         _controller.openDevTools();
            //       },
            //     )
            //   ]),
            // ),
            Expanded(
                child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      children: [
                        Webview(
                          _controller,
                          permissionRequested: _onPermissionRequested,
                        ),
                        StreamBuilder<LoadingState>(
                            stream: _controller.loadingState,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data == LoadingState.loading) {
                                return LinearProgressIndicator();
                              } else {
                                return SizedBox();
                              }
                            }),
                      ],
                    ))),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   tooltip: _isWebviewSuspended ? 'Resume webview' : 'Suspend webview',
      //   onPressed: () async {
      //     if (_isWebviewSuspended) {
      //       await _controller.resume();
      //     } else {
      //       await _controller.suspend();
      //     }
      //     setState(() {
      //       _isWebviewSuspended = !_isWebviewSuspended;
      //     });
      //   },
      //   child: Icon(_isWebviewSuspended ? Icons.play_arrow : Icons.pause),
      // ),
      // appBar: AppBar(
      //     title: StreamBuilder<String>(
      //       stream: _controller.title,
      //       builder: (context, snapshot) {
      //         return Text(
      //             snapshot.hasData ? snapshot.data! : 'WebView (Windows) Example');
      //       },
      //     )),
      body: Center(
        child: compositeView(),
      ),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _controller.dispose();
    super.dispose();
  }
}
