import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsPomodoro extends StatefulWidget {
  const SettingsPomodoro({super.key});

  @override
  State<SettingsPomodoro> createState() => _SettingsPomodoroState();
}

class _SettingsPomodoroState extends State<SettingsPomodoro> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Column(
            children: [
              Center(
                child: Text(
                  "Adjust Pomodoro",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 153, 105, 43),
                  ),
                ),
              ),
            ],
          ),
          leading: const SizedBox(
            width: 10,
            height: 10,
            child: Icon(
              Icons.alarm,
              color: Color.fromARGB(255, 153, 105, 43),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Color.fromARGB(255, 153, 105, 43),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: "25:00",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: "Pomodoro",
                          fillColor: Color.fromARGB(255, 228, 228, 228),
                          filled: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: "05:00",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: "Short Break",
                          fillColor: Color.fromARGB(255, 228, 228, 228),
                          filled: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: "15:00",
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: "Long Break",
                          fillColor: Color.fromARGB(255, 228, 228, 228),
                          filled: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                      child: Icon(
                    Icons.coffee,
                    color: Color.fromARGB(146, 153, 105, 43),
                  )),
                  SizedBox(width: 10),
                  Expanded(
                      child: Icon(
                    Icons.update_outlined,
                    color: Color.fromARGB(146, 153, 105, 43),
                  )),
                  SizedBox(width: 10),
                  Expanded(
                      child: Icon(
                    Icons.self_improvement_sharp,
                    color: Color.fromARGB(146, 153, 105, 43),
                  )),
                  SizedBox(width: 10),
                ],
              ),
              ElevatedButton(onPressed: () {}, child: Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}
