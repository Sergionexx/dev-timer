import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:devtimer/main.dart';
import 'package:devtimer/views/dialogs-views/settings-pomodoro.dart';
import 'package:devtimer/widgets/ads/ad-banner.dart';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _seconds = 25 * 60; // 25 minutos en segundos
  late Timer _timer;
  bool _isTimerRunning = false;
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.onlyShowSelected;

  List<String> coffeeGifs = [
    'assets/gifs/CoffeCompleteWhite0-4.gif',
    'assets/gifs/CoffeCompleteWhite1-4.gif',
    'assets/gifs/CoffeCompleteWhite2-4.gif',
    'assets/gifs/CoffeCompleteWhite3-4.gif',
    'assets/gifs/CoffeCompleteWhite4-4.gif',
  ];

  final int _totalSeconds = 25 * 60; // Tiempo total en segundos
  late int _interval; // Intervalo de cambio de imagen

  int _previousImageIndex = 0;

  int _currentImageIndex() {
    int index = (_seconds / _interval).floor();
    index = index.clamp(0, coffeeGifs.length - 1);

    // Verificar si el índice ha cambiado
    if (index != _previousImageIndex) {
      _playSlurpSound(); // Reproducir el sonido
      _previousImageIndex = index; // Actualizar el índice anterior
    }

    return index;
  }

  void _playSlurpSound() async {
    await _audioPlayer.play(AssetSource('sounds/coffee-slurp.mp3'));
  }

  generateDialog(dynamic classDialog, double heightCard) {
    return showDialog(
      context: context,
      barrierDismissible:
          false, // Evita que el diálogo se cierre al presionar fuera de él
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Center(
            // Centrar el diálogo en la pantalla
            child: Stack(
              children: [
                // Fondo distorsionado
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
                // Contenedor para centrar verticalmente
                Center(
                  child: SizedBox(
                    width: 500, // Define el ancho deseado
                    height: heightCard, // Define el alto deseado
                    child: Container(
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            10), // Definir bordes redondos
                        color: Colors
                            .white, // Cambiar color de fondo si es necesario
                      ),
                      child: classDialog,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _interval = (_totalSeconds / 5).floor();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    var status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      // Solicitar permiso si es necesario
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print("Permiso de notificaciones concedido");
      } else {
        print("Permiso de notificaciones denegado");
      }
    } else if (status.isGranted) {
      print("Permiso ya concedido");
    }
  }

  Future<void> _showNotification(seconds) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'timer_channel_id',
      'Timer Notifications',
      channelDescription: 'Shows the countdown timer',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      vibrationPattern: null,
      enableVibration: false,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Focus Time',
      'Time remaining: $seconds seconds',
      notificationDetails,
    );
  }

  Future<void> _showNotificationComplete() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'timer_channel_id',
      'Timer Notifications',
      channelDescription: 'Shows the countdown timer',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: false,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      1,
      'Timer Finished',
      'The timer has completed!',
      notificationDetails,
    );
  }

  void _startOrStopTimer() {
    if (_isTimerRunning) {
      _stopTimer(); // Detener el temporizador si está en marcha
    } else {
      _startTimer(); // Empezar el temporizador si está detenido
    }
  }

  void _stopTimer() {
    _timer.cancel(); // Detener el temporizador
    setState(() {
      _seconds = 25 * 60;
      _isTimerRunning = false; // Cambiar el estado a detenido
    });
    // _updateNotification(0);
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true; // El temporizador ha comenzado
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer?.cancel(); // Detener el temporizador cuando llegue a 0
        _showNotificationComplete();
        setState(() {
          _isTimerRunning = false; // El temporizador ha terminado
        });
      }
    });
  }

  // Actualizar la notificación con el tiempo restante
  Future<void> _updateNotification(seconds) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'timer_channel_id',
      'Timer Notifications',
      channelDescription: 'Shows the countdown timer',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true, // Mantener la notificación en segundo plano
      vibrationPattern: Int64List.fromList([]), // Sin vibración
      enableVibration: false, // Desactiva la vibración
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // ID de la notificación (se mantiene el mismo ID)
      'Timer Countdown',
      'Time remaining: $seconds seconds', // Mostrar el tiempo restante
      notificationDetails,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose(); // Asegúrate de liberar el AudioPlayer
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    return '${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  String _twoDigits(int n) {
    return n >= 10 ? '$n' : '0$n';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Container(
          margin: const EdgeInsets.only(left: 5),
          child: Text(widget.title),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Icon(Icons.coffee,
                size: 90, color: Color.fromARGB(255, 153, 105, 43)),
            ListTile(
              leading: Icon(Icons.access_alarms_rounded),
              title: Text('Adjust pomodoro'),
              onTap: () {
                generateDialog(SettingsPomodoro(), 200);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 0, 0)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formattedTime,
                style: const TextStyle(
                  fontFamily: "Tiny5",
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Image.asset(
                coffeeGifs[
                    _currentImageIndex()], // Cambia la imagen según el índice
                height: 425.0,
                width: 425.0,
              ),
              // const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(
                            15), // Ensure padding for circular shape
                      ),
                      onPressed:
                          _startOrStopTimer, // Llamar al método que empieza o detiene el temporizador
                      child: Icon(
                          _isTimerRunning ? Icons.pause : Icons.play_arrow),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(
                            15), // Ensure padding for circular shape
                      ),
                      onPressed:
                          _startOrStopTimer, // Llamar al método que empieza o detiene el temporizador
                      child: Icon(Icons.stop),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(
                            15), // Ensure padding for circular shape
                      ),
                      onPressed:
                          _startOrStopTimer, // Llamar al método que empieza o detiene el temporizador
                      child: Icon(Icons.volume_off),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [        
        NavigationBar(
          labelBehavior: labelBehavior,
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Color.fromARGB(255, 240, 185, 113),
          backgroundColor: const Color.fromARGB(255, 153, 105, 43),
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(
                Icons.coffee,
                color: Color.fromARGB(255, 153, 105, 43),
              ),
              icon: Icon(Icons.coffee, color: Color.fromARGB(255, 240, 185, 113)),
              label: 'Pomodoro',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.update_outlined,
                color: const Color.fromARGB(255, 153, 105, 43),
              ),
              icon: Icon(
                Icons.update_outlined,
                color: Color.fromARGB(255, 240, 185, 113),
              ),
              label: 'Short Break',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.self_improvement_sharp,
                color: const Color.fromARGB(255, 153, 105, 43),
              ),
              icon: Icon(
                Icons.self_improvement_sharp,
                color: Color.fromARGB(255, 240, 185, 113),
              ),
              label: 'Long Break',
            ),
          ],
        ),
        AdBanner(), // Aquí se muestra el banner de anuncios
      ],
    ),
    );
  }
}
