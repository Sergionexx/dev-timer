import 'dart:async';
import 'dart:ui';

import 'package:devtimer/main.dart';
import 'package:devtimer/views/dialogs-views/settings-pomodoro.dart';
import 'package:devtimer/widgets/ads/ad-banner.dart';
import 'package:devtimer/widgets/tasks_widget.dart';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:audioplayers/audioplayers.dart';

enum TimerState { pomodoro, shortBreak, longBreak }

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _seconds = 25 * 60; // 25 minutos en segundos por defecto
  late Timer _timer;
  bool _isTimerRunning = false;
  int currentPageIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior =
      NavigationDestinationLabelBehavior.onlyShowSelected;

  // Variable para forzar la actualización del widget de tareas
  int _taskUpdateCounter = 0;

  // Tiempos configurables
  int _pomodoroTime = 25 * 60; // 25 minutos por defecto
  int _shortBreakTime = 5 * 60; // 5 minutos por defecto
  int _longBreakTime = 15 * 60; // 15 minutos por defecto

  // Estado actual del timer
  TimerState _currentState = TimerState.pomodoro;

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

    // Verificar si el índice ha cambiado y si el temporizador está corriendo
    if (_isTimerRunning && index != _previousImageIndex) {
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
    _loadSavedTimes();
  }

  void _loadSavedTimes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pomodoroTime =
          _parseTimeToSeconds(prefs.getString('pomodoro_time') ?? '25:00');
      _shortBreakTime =
          _parseTimeToSeconds(prefs.getString('short_break_time') ?? '05:00');
      _longBreakTime =
          _parseTimeToSeconds(prefs.getString('long_break_time') ?? '15:00');
      _seconds = _pomodoroTime; // Inicializar con tiempo pomodoro
    });
  }

  int _parseTimeToSeconds(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return 25 * 60; // Valor por defecto

    final minutes = int.tryParse(parts[0]) ?? 25;
    final seconds = int.tryParse(parts[1]) ?? 0;

    return (minutes * 60) + seconds;
  }

  void _updateTimerState(TimerState newState) {
    if (_isTimerRunning) return; // No cambiar si el timer está corriendo

    setState(() {
      _currentState = newState;
      // Sincronizar el currentPageIndex con el estado
      switch (newState) {
        case TimerState.pomodoro:
          _seconds = _pomodoroTime;
          currentPageIndex = 0;
          break;
        case TimerState.shortBreak:
          _seconds = _shortBreakTime;
          currentPageIndex = 1;
          break;
        case TimerState.longBreak:
          _seconds = _longBreakTime;
          currentPageIndex = 2;
          break;
      }
    });
  }

  void _onTimesUpdated(
      int pomodoroTime, int shortBreakTime, int longBreakTime) {
    setState(() {
      _pomodoroTime = pomodoroTime;
      _shortBreakTime = shortBreakTime;
      _longBreakTime = longBreakTime;

      // Actualizar el tiempo actual si no está corriendo
      if (!_isTimerRunning) {
        switch (_currentState) {
          case TimerState.pomodoro:
            _seconds = _pomodoroTime;
            break;
          case TimerState.shortBreak:
            _seconds = _shortBreakTime;
            break;
          case TimerState.longBreak:
            _seconds = _longBreakTime;
            break;
        }
      }
    });
  }

  void _onTasksUpdated() {
    setState(() {
      _taskUpdateCounter++;
    });
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
      // Reiniciar con el tiempo correspondiente al estado actual
      switch (_currentState) {
        case TimerState.pomodoro:
          _seconds = _pomodoroTime;
          break;
        case TimerState.shortBreak:
          _seconds = _shortBreakTime;
          break;
        case TimerState.longBreak:
          _seconds = _longBreakTime;
          break;
      }
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
        _timer.cancel(); // Detener el temporizador cuando llegue a 0
        _showNotificationComplete();
        setState(() {
          _isTimerRunning = false; // El temporizador ha terminado
        });
      }
    });
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

  String get _currentStateTitle {
    switch (_currentState) {
      case TimerState.pomodoro:
        return "Focus Time";
      case TimerState.shortBreak:
        return "Short Break";
      case TimerState.longBreak:
        return "Long Break";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Coffeodoro",
          style: const TextStyle(
            fontFamily: "Pixelify",
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.task_alt,
              color: Color.fromARGB(255, 153, 105, 43),
              size: 28,
            ),
            onPressed: () {
              generateDialog(
                SettingsPomodoro(
                  onTimesUpdated: _onTimesUpdated,
                  onTasksUpdated: _onTasksUpdated,
                ),
                600,
              );
            },
            tooltip: 'Configurar Pomodoro y Tareas',
          ),
        ],
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
                generateDialog(
                    SettingsPomodoro(
                      onTimesUpdated: _onTimesUpdated,
                      onTasksUpdated: _onTasksUpdated,
                    ),
                    200);
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
        child: SafeArea(
          child: Column(
            children: [
              // Header con título del estado actual
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _currentStateTitle,
                  style: const TextStyle(
                    fontFamily: "Tiny5",
                    color: Color.fromARGB(255, 153, 105, 43),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Contenido principal que se expande
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Timer
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontFamily: "Tiny5",
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Imagen flexible que se adapta al espacio disponible
                    Flexible(
                      flex: 2,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          constraints: const BoxConstraints(
                            maxWidth: 350.0,
                            maxHeight: 350.0,
                          ),
                          child: Image.asset(
                            coffeeGifs[_currentImageIndex()],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Widget de tareas
                    Flexible(
                      flex: 1,
                      child: TasksWidget(key: ValueKey(_taskUpdateCounter)),
                    ),
                  ],
                ),
              ),

              // Botones de control fijos en la parte inferior
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const SizedBox(width: 30),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: _startOrStopTimer,
                        child: Icon(
                            _isTimerRunning ? Icons.pause : Icons.play_arrow),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: _startOrStopTimer,
                        child: const Icon(Icons.stop),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: _startOrStopTimer,
                        child: const Icon(Icons.volume_off),
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
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
              // Cambiar el estado del timer según la opción seleccionada
              switch (index) {
                case 0:
                  _updateTimerState(TimerState.pomodoro);
                  break;
                case 1:
                  _updateTimerState(TimerState.shortBreak);
                  break;
                case 2:
                  _updateTimerState(TimerState.longBreak);
                  break;
              }
            },
            indicatorColor: Color.fromARGB(255, 240, 185, 113),
            backgroundColor: const Color.fromARGB(255, 153, 105, 43),
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.coffee,
                  color: Color.fromARGB(255, 153, 105, 43),
                ),
                icon: Icon(Icons.coffee,
                    color: Color.fromARGB(255, 240, 185, 113)),
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
