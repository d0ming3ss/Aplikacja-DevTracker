import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProjectDTO {
  final int id;
  final String? name;

  ProjectDTO({required this.id, this.name});

  factory ProjectDTO.fromJson(Map<String, dynamic> json) {
    return ProjectDTO(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class UserDTO {
  final int id;
  final String? firstName;
  final String? lastName;

  UserDTO({required this.id, this.firstName, this.lastName});

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class TaskDTO {
  final int id;
  final String? name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectDTO? project;
  final Set<UserDTO>? users;
  bool completed;

  TaskDTO({
    required this.id,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.project,
    this.users,
    this.completed = false,
  });

  factory TaskDTO.fromJson(Map<String, dynamic> json) {
    return TaskDTO(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      project:
          json['project'] != null ? ProjectDTO.fromJson(json['project']) : null,
      users: (json['users'] as List<dynamic>?)
          ?.map((userJson) => UserDTO.fromJson(userJson))
          .toSet(),
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'project': project?.toJson(),
      'users': users?.map((user) => user.toJson()).toList(),
      'completed': completed,
    };
  }
}

class TaskProgPage extends StatefulWidget {
  const TaskProgPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskProgPage> {
  List<TaskDTO> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse('http://localhost:8080/tasks'));

    if (response.statusCode == 200) {
      setState(() {
        tasks = (jsonDecode(response.body) as List<dynamic>)
            .map((json) => TaskDTO.fromJson(json))
            .toList();
      });
      await loadTaskStatus();
    } else {
      throw Exception('Nie udało się pobrać zadań');
    }
  }

  Future<void> loadTaskStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var task in tasks) {
      bool? completed = prefs.getBool('task_${task.id}');
      if (completed != null) {
        task.completed = completed;
      }
    }
    setState(() {});
  }

  Future<void> saveTaskStatus(int taskId, bool completed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('task_$taskId', completed);
  }

  Future<void> deleteTask(int taskId) async {
    final response =
        await http.delete(Uri.parse('http://localhost:8080/tasks/$taskId'));

    if (response.statusCode == 204) {
      setState(() {
        tasks.removeWhere((task) => task.id == taskId);
      });
    } else {
      throw Exception('Nie udało się usunąć zadania');
    }
  }

  Future<void> updateTaskStatus(int taskId, bool completed) async {
    final response = await http.patch(
      Uri.parse('http://localhost:8080/tasks/$taskId/complete'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"completed": completed}),
    );

    if (response.statusCode == 200) {
      setState(() {
        tasks = tasks.map((task) {
          if (task.id == taskId) {
            saveTaskStatus(taskId, completed);
            return TaskDTO(
              id: task.id,
              name: task.name,
              description: task.description,
              startDate: task.startDate,
              endDate: task.endDate,
              project: task.project,
              users: task.users,
              completed: completed,
            );
          }
          return task;
        }).toList();
      });
    } else {
      throw Exception('Nie udało się zaktualizować statusu zadania');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wszystkie Zadania'),
      ),
      body: tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final project = task.project;
                final users = task.users;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      task.name ?? 'Nazwa nieznana',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opis: ${task.description ?? "Brak opisu"}',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        Text(
                          'Projekt: ${project != null ? project.name ?? "Brak" : "Brak"}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                            'Data rozpoczęcia: ${task.startDate ?? "Nieznana"}'),
                        Text('Data zakończenia: ${task.endDate ?? "Nieznana"}'),
                        const SizedBox(height: 8),
                        const Text('Przypisani użytkownicy:'),
                        if (users != null && users.isNotEmpty)
                          ...users
                              .map((user) => Text(
                                    '${user.firstName ?? ""} ${user.lastName ?? ""}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ))
                              .toList()
                        else
                          const Text("Brak przypisanych użytkowników"),
                        Text(
                          task.completed ? 'DONE' : 'IN PROGRESS',
                          style: TextStyle(
                            color:
                                task.completed ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task.completed,
                          onChanged: (bool? value) {
                            if (value != null) {
                              updateTaskStatus(task.id, value);
                            }
                          },
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.delete, color: Colors.red),
                        //   onPressed: () async {
                        //     final confirmDelete = await showDialog(
                        //       context: context,
                        //       builder: (context) => AlertDialog(
                        //         title: const Text('Potwierdzenie usunięcia'),
                        //         content: const Text(
                        //             'Czy na pewno chcesz usunąć to zadanie?'),
                        //         actions: [
                        //           TextButton(
                        //             onPressed: () =>
                        //                 Navigator.of(context).pop(false),
                        //             child: const Text('Anuluj'),
                        //           ),
                        //           TextButton(
                        //             onPressed: () =>
                        //                 Navigator.of(context).pop(true),
                        //             child: const Text('Usuń'),
                        //           ),
                        //         ],
                        //       ),
                        //     );

                        //     if (confirmDelete == true) {
                        //       await deleteTask(task.id);
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
