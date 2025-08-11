import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/task_service.dart';
import '../../models/task.dart';

class SettingsPomodoro extends StatefulWidget {
  final Function(int, int, int)? onTimesUpdated;
  final VoidCallback? onTasksUpdated;

  const SettingsPomodoro({super.key, this.onTimesUpdated, this.onTasksUpdated});

  @override
  State<SettingsPomodoro> createState() => _SettingsPomodoroState();
}

class _SettingsPomodoroState extends State<SettingsPomodoro> {
  final TextEditingController _pomodoroController = TextEditingController();
  final TextEditingController _shortBreakController = TextEditingController();
  final TextEditingController _longBreakController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
  }

  void _loadSavedTimes() async {
    final prefs = await SharedPreferences.getInstance();
    _pomodoroController.text = prefs.getString('pomodoro_time') ?? '25:00';
    _shortBreakController.text = prefs.getString('short_break_time') ?? '05:00';
    _longBreakController.text = prefs.getString('long_break_time') ?? '15:00';
    _tasks = await TaskService.loadTasks();
    setState(() {});
  }

  void _addTask() async {
    final task = _taskController.text.trim();
    if (task.isNotEmpty) {
      await TaskService.addTask(task);
      setState(() {
        _taskController.clear();
      });
      _tasks = await TaskService.loadTasks();
      setState(() {});
      if (widget.onTasksUpdated != null) {
        widget.onTasksUpdated!();
      }
    }
  }

  void _removeTask(int index) async {
    if (index >= 0 && index < _tasks.length) {
      await TaskService.deleteTask(_tasks[index].id);
      _tasks = await TaskService.loadTasks();
      setState(() {});
      if (widget.onTasksUpdated != null) {
        widget.onTasksUpdated!();
      }
    }
  }

  int _parseTimeToSeconds(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return 0;

    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;

    return (minutes * 60) + seconds;
  }

  bool _validateTimeInput(String input) {
    final regex = RegExp(r'^\d{1,2}:\d{2}$');
    return regex.hasMatch(input);
  }

  void _saveTimes() async {
    if (!_validateTimeInput(_pomodoroController.text) ||
        !_validateTimeInput(_shortBreakController.text) ||
        !_validateTimeInput(_longBreakController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid times in MM:SS format'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pomodoro_time', _pomodoroController.text);
    await prefs.setString('short_break_time', _shortBreakController.text);
    await prefs.setString('long_break_time', _longBreakController.text);
    // No need to save tasks here as they are handled by TaskService

    if (widget.onTimesUpdated != null) {
      widget.onTimesUpdated!(
        _parseTimeToSeconds(_pomodoroController.text),
        _parseTimeToSeconds(_shortBreakController.text),
        _parseTimeToSeconds(_longBreakController.text),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Times and tasks saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _pomodoroController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: "Pomodoro",
                            hintText: "MM:SS",
                            fillColor: Color.fromARGB(255, 228, 228, 228),
                            filled: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _shortBreakController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: "Short Break",
                            hintText: "MM:SS",
                            fillColor: Color.fromARGB(255, 228, 228, 228),
                            filled: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _longBreakController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: "Long Break",
                            hintText: "MM:SS",
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _taskController,
                          decoration: InputDecoration(
                            labelText: "Agregar tarea u objetivo",
                            hintText: "Ej: Terminar reporte",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            fillColor: Color.fromARGB(255, 245, 245, 245),
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 153, 105, 43),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.add_task),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tareas/Objetivos:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 153, 105, 43),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ..._tasks.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final task = entry.value;
                        return Card(
                          color: const Color.fromARGB(255, 255, 249, 240),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ListTile(
                            title: Text(task.title),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeTask(idx),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveTimes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 153, 105, 43),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Guardar todo"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pomodoroController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    _taskController.dispose();
    super.dispose();
  }
}
