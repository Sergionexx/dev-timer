import 'dart:async';
import 'dart:ui';

import 'package:devtimer/views/dialogs-views/settings-pomodoro.dart';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _seconds = 25 * 60; // 25 minutos en segundos
  late Timer _timer;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer.cancel(); // Detener el temporizador cuando llegue a 0
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    return '${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    } else {
      return '0$n';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Container(
          margin: const EdgeInsets.only(left: 5),
          child: Text(
            widget.title,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Icon(
              Icons.coffee,
              size: 90,
              color: Color.fromARGB(255, 153, 105, 43),
            ),
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
                    fontFamily: "Doto",
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.w500),
              ),
              Image.asset(
                'assets/gifs/CoffeCompleteWhite.gif',
                height: 425.0,
                width: 425.0,
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  _startTimer();
                },
                child: const Text('Star Day'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
