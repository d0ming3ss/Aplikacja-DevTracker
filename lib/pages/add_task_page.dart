import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Project {
  final String id;
  final String name;

  Project({required this.id, required this.name});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'].toString(),
      name: json['name'],
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;

  User({required this.id, required this.fullName, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    print('Otrzymano dane użytkownika: $json');

    String fullName = '${json['firstName']} ${json['lastName']}';

    return User(
      id: json['id'].toString(),
      fullName: fullName,
      email: json['email'],
    );
  }
}

class Task {
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String projectId;
  final List<String> assignedUsers;

  Task({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.projectId,
    required this.assignedUsers,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      // 'userIds': assignedUsers,
    };
  }
}

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  String? _selectedProjectId;
  String _taskName = '';
  String _taskDescription = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<Project> _projects = [];
  List<User> _projectUsers = [];
  List<String> _selectedUserIds = [];
  bool _nameError = false;
  bool _descriptionError = false;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/projects'));

      if (response.statusCode == 200) {
        List<dynamic> projectsJson = jsonDecode(response.body);

        setState(() {
          _projects =
              projectsJson.map((json) => Project.fromJson(json)).toList();
        });
      } else {
        print('Błąd podczas pobierania projektów: ${response.statusCode}');
      }
    } catch (e) {
      print('Błąd: $e');
    }
  }

  Future<void> fetchProjectUsers(String projectId) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:8080/projects/$projectId/users'));

      if (response.statusCode == 200) {
        List<dynamic> usersJson = jsonDecode(response.body);
        print('Przypisani użytkownicy: $usersJson');
        setState(() {
          _projectUsers = usersJson.map((json) => User.fromJson(json)).toList();
          _selectedUserIds.clear();
        });
      } else {
        print('Błąd podczas pobierania użytkowników: ${response.statusCode}');
      }
    } catch (e) {
      print('Błąd: $e');
    }
  }

  Future<void> _submitTask() async {
    setState(() {
      _nameError = _taskName.isEmpty;
      _descriptionError = _taskDescription.isEmpty;
    });

    if (_selectedProjectId != null && !_nameError && !_descriptionError) {
      Task newTask = Task(
        name: _taskName,
        description: _taskDescription,
        startDate: _startDate,
        endDate: _endDate,
        projectId: _selectedProjectId!,
        assignedUsers: _selectedUserIds,
      );

      try {
        final response = await http.post(
          Uri.parse(
            'http://localhost:8080/tasks/projects/${_selectedProjectId}/assign-users?userIds=${_selectedUserIds.join(',')}',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newTask.toJson()),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Zadanie zostało pomyślnie dodane')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Błąd podczas dodawania zadania: ${response.body}')),
          );
          throw Exception('Failed to create task');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas dodawania zadania: $e')),
        );
        print('Error creating task: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proszę wybrać projekt i poprawić błędy')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dodaj zadanie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              hint: Text('Wybierz projekt'),
              value: _selectedProjectId,
              onChanged: (String? value) {
                setState(() {
                  _selectedProjectId = value;
                  if (_selectedProjectId != null) {
                    fetchProjectUsers(_selectedProjectId!);
                  }
                });
              },
              items: _projects.map((Project project) {
                return DropdownMenuItem<String>(
                  value: project.id,
                  child: Text(project.name),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              hint: Text('Wybierz użytkowników'),
              isExpanded: true,
              value: _selectedUserIds.isNotEmpty ? _selectedUserIds[0] : null,
              onChanged: (String? userId) {
                setState(() {
                  if (userId != null) {
                    if (_selectedUserIds.contains(userId)) {
                      _selectedUserIds.remove(userId);
                    } else {
                      _selectedUserIds.add(userId);
                    }
                  }
                });
              },
              items: _projectUsers.map((User user) {
                return DropdownMenuItem<String>(
                  value: user.id,
                  child: Text(user.fullName),
                );
              }).toList(),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nazwa zadania',
                errorText:
                    _nameError ? 'Nazwa zadania nie może być pusta' : null,
              ),
              onChanged: (value) {
                setState(() {
                  _taskName = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Opis zadania',
                errorText: _descriptionError
                    ? 'Opis zadania nie może być pusty'
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _taskDescription = value;
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Data rozpoczęcia: ${_startDate.toLocal()}'
                        .split(' ')[0]),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Data zakończenia: ${_endDate.toLocal()}'
                        .split(' ')[0]),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _submitTask,
              child: Text('Utwórz zadanie'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null &&
        pickedDate != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }
}
