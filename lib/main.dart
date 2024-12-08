import 'package:devtimer/views/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dev Timer',
        initialRoute: '/',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE6A24A)),
          useMaterial3: true,
        ),
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => const HomePage(title: 'Dev Timer'),
        });
  }
}
