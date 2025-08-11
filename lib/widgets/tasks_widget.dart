import 'package:flutter/material.dart';
import '../models/task.dart';
import '../service/task_service.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({super.key});

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  List<Task> _tasks = [];
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final tasks = await TaskService.loadTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  void _toggleTaskCompletion(String taskId) async {
    await TaskService.toggleTaskCompletion(taskId);
    _loadTasks();
  }

  void _deleteTask(String taskId) async {
    await TaskService.deleteTask(taskId);
    _loadTasks();
  }

  void _deleteCompletedTasks() async {
    final completedTasks = _tasks.where((task) => task.isCompleted).toList();
    for (final task in completedTasks) {
      await TaskService.deleteTask(task.id);
    }
    _loadTasks();
  }

  List<Task> get _filteredTasks {
    if (_showCompleted) {
      return _tasks;
    } else {
      return _tasks.where((task) => !task.isCompleted).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Text(
            'No hay tareas. ¡Añade algunas desde configuración!',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final completedCount = _tasks.where((task) => task.isCompleted).length;
    final totalCount = _tasks.length;

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 153, 105, 43),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(
                  Icons.task_alt,
                  color: Color.fromARGB(255, 153, 105, 43),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tareas ($completedCount/$totalCount)',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 153, 105, 43),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Toggle para mostrar/ocultar completadas
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCompleted = !_showCompleted;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _showCompleted
                          ? const Color.fromARGB(255, 153, 105, 43)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color.fromARGB(255, 153, 105, 43),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _showCompleted ? 'Todas' : 'Pendientes',
                      style: TextStyle(
                        color: _showCompleted
                            ? Colors.white
                            : const Color.fromARGB(255, 153, 105, 43),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (completedCount > 0) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar completadas'),
                          content: Text(
                              '¿Eliminar todas las $completedCount tareas completadas?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteCompletedTasks();
                              },
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.delete_sweep,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Lista de tareas
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return Container(
                  margin: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: GestureDetector(
                      onTap: () => _toggleTaskCompletion(task.id),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted
                              ? Colors.green
                              : Colors.transparent,
                          border: Border.all(
                            color: task.isCompleted
                                ? Colors.green
                                : Colors.white54,
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        color: task.isCompleted ? Colors.white54 : Colors.white,
                        fontSize: 14,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () => _deleteTask(task.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
