
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class notificationPage extends StatefulWidget {
  @override
  _notificationPageState createState() => _notificationPageState();
}

class _notificationPageState extends State<notificationPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future onSelectNotification(String payload) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Payload"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  Future<void> _showNotification() async {
    var androidDetails = const AndroidNotificationDetails(
        "channelId", "Local Notification",
        importance: Importance.high);
    var generalNotificationDetails =
    NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
        0, "Warning", "Hello world!", generalNotificationDetails,
        payload: "Welcome to the Local Notification demo");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter Local Notification"),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _showNotification,
            child: Text("Show Notification"),
          ),
        ),
      ),
    );
  }
}
