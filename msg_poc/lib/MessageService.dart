import 'package:advance_notification/advance_notification.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_dart/database.dart';
import 'package:firebase_dart/src/core.dart';
import 'package:flutter/material.dart';
import 'package:m_toast/m_toast.dart';
import 'package:msg_poc/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message.dart' as msg;

class MessageService extends StatefulWidget {
  const MessageService({required this.app, super.key});

  final FirebaseApp app;

  @override
  State<MessageService> createState() => _MessageServiceState();
}

class _MessageServiceState extends State<MessageService> {
  final _winNotifyPlugin = WindowsNotification(applicationId: "Test Application"
      // r"{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}\WindowsPowerShell\v1.0\powershell.exe"
      );
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late FirebaseApp _app;
  // static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  StreamSubscription? dbSub;
  // static final FlutterLocalNotificationsPlugin LocalNotification = FlutterLocalNotificationsPlugin();

  @override
  void initState()  {
    super.initState();
    _app = widget.app;
    _winNotifyPlugin
        .initNotificationCallBack((notification, status, argruments) {
      print("aargs: $argruments");
    }); //Start listening to our RTDB
    dbSub = startListening();
  }

  @override
  void dispose() {
    dbSub?.cancel(); //Stop listening - Must be called to prevent a memory-leak
    super.dispose();
  }

  StreamSubscription? startListening() {
    FirebaseDatabase db = FirebaseDatabase(
        app: _app,
        databaseURL: 'https://fir-msg-database-default-rtdb.firebaseio.com/');

    db.goOnline();
    return db.reference().onValue.listen((event) async {
      SharedPreferences prefs = await _prefs;
      final data = event.snapshot.value;
      print(data);
      // print(data['message']);
      // final res = data['message'];
      if (data != null &&
          data['title'] != null &&
          data['subtitle'] != null &&
          data['id'] != null &&
          data['title'] != '' &&
          data['subtitle'] != '') {
        msg.Message message = msg.Message.fromMap(data);
        print("MEssage :: $message");
        if (prefs.getInt('id') != message.id) {
          NotificationMessage _message = NotificationMessage.fromPluginTemplate(
            "#001",
            message.title,
            message.subtitle ?? "",
          );
          ShowMToast toast = ShowMToast();
          _winNotifyPlugin.showNotificationPluginTemplate(_message);
        }
        await prefs.setInt('id', message.id);
      }
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}
