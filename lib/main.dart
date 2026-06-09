import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'providers/task_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Local notifications setup
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Request FCM permission
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // Foreground FCM
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'taskflow_channel',
            'TaskFlow Notifications',
            channelDescription: 'Task reminders and updates',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });

  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
