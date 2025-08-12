import 'package:devtimer/views/home.dart';
import 'package:devtimer/views/login_screen.dart';
import 'package:devtimer/views/profile_screen.dart';
import 'package:devtimer/views/recovery_password_screen.dart';
import 'package:devtimer/views/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  // Configuración para Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Configuración para iOS
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Configuración general
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Coffie: Pomodoro & Tasks',
        initialRoute: '/',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE6A24A)),
          useMaterial3: false, // Deshabilitar Material 3 para evitar problemas con MouseTracker
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'PixelifySans'),
            bodyMedium: TextStyle(fontFamily: 'PixelifySans'),
            bodySmall: TextStyle(fontFamily: 'PixelifySans'),
            titleLarge: TextStyle(fontFamily: 'PixelifySans'),
            titleMedium: TextStyle(fontFamily: 'PixelifySans'),
            titleSmall: TextStyle(fontFamily: 'PixelifySans'),
            labelLarge: TextStyle(fontFamily: 'PixelifySans'),
            labelMedium: TextStyle(fontFamily: 'PixelifySans'),
            labelSmall: TextStyle(fontFamily: 'PixelifySans'),
          ),
        ),
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) =>
              HomePage(title: 'Coffodoro: Pomodoro & Tasks'),
          '/home': (context) => const HomePage(title: 'Dev Timer'),
          //   '/register': (context) => RegisterScreen(),
          //  '/profile': (context) => ProfileScreen(),
          //  '/recovery': (context) => RecoveryPasswordScreen(),
        });
  }
}
