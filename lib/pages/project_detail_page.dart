import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProjectDetailPage extends StatefulWidget {
  final dynamic project;

  const ProjectDetailPage({Key? key, required this.project}) : super(key: key);

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  List<dynamic> _users = [];
  List<dynamic> _assignedUsers = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.project['name'];
    _descriptionController.text = widget.project['description'];
    _startDateController.text = widget.project['startDate'] ?? '';
    _endDateController.text = widget.project['endDate'] ?? '';
    _fetchAssignedUsers().then((_) {
      _fetchUsers();
    });
  }

  Future<void> updateProject() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final String startDate = _startDateController.text;
    final String endDate = _endDateController.text;

    if (name.isNotEmpty && description.isNotEmpty) {
      try {
        final response = await http.put(
          Uri.parse('http://localhost:8080/projects/${widget.project['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'description': description,
            'startDate': startDate.isNotEmpty ? startDate : null,
            'endDate': endDate.isNotEmpty ? endDate : null,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Projekt zaktualizowany pomyślnie!")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Błąd podczas aktualizacji projektu: ${response.reasonPhrase}")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Wystąpił błąd: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Proszę wprowadzić wszystkie dane.")));
    }
  }

  Future<void> deleteProject() async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/projects/${widget.project['id']}'),
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Projekt usunięty pomyślnie!")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Błąd podczas usuwania projektu: ${response.reasonPhrase}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Wystąpił błąd: $e")));
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/users'));
      if (response.statusCode == 200) {
        setState(() {
          _users = jsonDecode(response.body);
          _users.removeWhere((user) => _assignedUsers
              .any((assignedUser) => assignedUser['id'] == user['id']));
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> _fetchAssignedUsers() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:8080/projects/${widget.project['id']}/users'));
      if (response.statusCode == 200) {
        setState(() {
          _assignedUsers = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching assigned users: $e');
    }
  }

  Future<void> _assignUserToProject(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:8080/projects/${widget.project['id']}/users/$userId'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Użytkownik przypisany pomyślnie')));

        setState(() {
          _users.removeWhere((user) => user['id'] == userId);
        });

        _fetchAssignedUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd przypisywania użytkownika')));
      }
    } catch (e) {
      print('Error assigning user: $e');
    }
  }

  Future<void> _removeUserFromProject(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://localhost:8080/projects/${widget.project['id']}/users/$userId'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Użytkownik usunięty pomyślnie')));

        setState(() {
          final removedUser = _assignedUsers
              .firstWhere((user) => user['id'] == userId, orElse: () => null);
          if (removedUser != null) {
            _users.add(removedUser);
          }
        });

        _fetchAssignedUsers();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Błąd usuwania użytkownika')));
      }
    } catch (e) {
      print('Error removing user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Szczegóły projektu")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nazwa projektu'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Opis projektu'),
            ),
            TextField(
              controller: _startDateController,
              decoration:
                  InputDecoration(labelText: 'Data rozpoczęcia (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _endDateController,
              decoration:
                  InputDecoration(labelText: 'Data zakończenia (YYYY-MM-DD)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateProject,
              child: Text("Zaktualizuj Projekt"),
            ),
            ElevatedButton(
              onPressed: () => deleteProject(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Usuń Projekt"),
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Przypisani użytkownicy:',
                          style: TextStyle(fontSize: 18)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _assignedUsers.length,
                        itemBuilder: (context, index) {
                          final user = _assignedUsers[index];
                          return ListTile(
                            title: Text(
                                '${user['firstName']} ${user['lastName']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () =>
                                  _removeUserFromProject(user['id']),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      Text('Dostępni użytkownicy:',
                          style: TextStyle(fontSize: 18)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return ListTile(
                            title: Text(
                                '${user['firstName']} ${user['lastName']}'),
                            subtitle: Text('Rola: ${user['roles']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  _assignUserToProject(int.parse(user['id'])),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
