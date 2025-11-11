import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart'; // optional if you want to send token to backend

// 🔔 Handles background messages (when app is terminated or backgrounded)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔹 Background message received: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize local notifications (for foreground display)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const GymApp());
}

class GymApp extends StatefulWidget {
  const GymApp({super.key});

  @override
  State<GymApp> createState() => _GymAppState();
}

class _GymAppState extends State<GymApp> {
  @override
  void initState() {
    super.initState();
    _initFirebaseMessaging();
  }

  /// Initialize Firebase Messaging
  Future<void> _initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Ask for notification permission (required for iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 Notification permission: ${settings.authorizationStatus}');

    // Get the device token
    String? token = await messaging.getToken();
    print("📱 FCM Device Token: $token");

    if (token != null) {
      // Optional: Send token to your backend
      // await sendTokenToServer(token);
    }

    // Handle foreground messages (when app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received!');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Show local notification
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel', // channel id
              'General Notifications', // channel name
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
            ),
          ),
        );
      }
    });

    // Handle when notification is clicked
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 Notification clicked!');
      print('Data: ${message.data}');
      // Example: You can navigate to a page based on message.data
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Management Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
