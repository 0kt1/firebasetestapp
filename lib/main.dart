import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_noti/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> firebaseMessagingBackgroundNotifications(
    RemoteMessage message) async {
  print("handling background msg : ${message.messageId}");
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: "Firebase push notifications",
        // theme: ThemeData(
        //   primaryColor: Colors.blue,
        // ),
        debugShowCheckedModeBanner: false,
        home: Homepage(),
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late FirebaseMessaging messaging;
  late PushNotification _notification;

  void registerNotification() async {
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundNotifications);

    NotificationSettings notificationSettings =
        await messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
            message.notification!.title.toString(),
            message.notification!.body.toString(),
            message.data["title"],
            message.data["body"]);

        setState(() {
          _notification = notification;
        });
        if (_notification != null) {
          showSimpleNotification(Text(_notification.title),
              subtitle: Text(_notification.body),
              background: Colors.cyan.shade700,
              duration: Duration(seconds: 2));
        }
      });
    } else {
      print("User declinded permissions");
    }
  }

  checkForInitialMessage() async {
    
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    RemoteMessage? initialMsg = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMsg != null) {
      PushNotification notification = PushNotification(
          initialMsg.notification!.title.toString(),
          initialMsg.notification!.body.toString(),
          initialMsg.data["title"],
          initialMsg.data["body"]);
      setState(() {
        _notification = notification;
      });
    }
  }

  @override
  void initState() {
    registerNotification();
    checkForInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          message.data["title"],
          message.data["body"]);

      setState(() {
        _notification = notification;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebas Push Notifications"),
      ),
      body: Center(
        child: Text(
          "Firebase Push Notification App", 
          textAlign: TextAlign.center, 
          style: TextStyle(
            color: Colors.black,
            fontSize: 20
          ),
        ),
      ),
    );
  }
}

class PushNotification {
  late String title, body, datatitle, databody;

  PushNotification(this.title, this.body, this.datatitle, this.databody);
}
