import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Model Project
class Project {
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  Project({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}

class DatePages extends StatefulWidget {
  @override
  _DatePagesState createState() => _DatePagesState();
}

class _DatePagesState extends State<DatePages> {
  late Future<List<Project>> futureProjects;

  @override
  void initState() {
    super.initState();
    futureProjects = fetchProjects();
  }

  // Funkcja do pobierania projektów z API
  Future<List<Project>> fetchProjects() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/projects'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((project) => Project.fromJson(project)).toList();
    } else {
      throw Exception('Nie udało się załadować projektów');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harmonogramy'),
      ),
      body: FutureBuilder<List<Project>>(
        future: futureProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Wystąpił błąd: ${snapshot.error}'));
          } else {
            final projects = snapshot.data!;
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                final daysLeft = _calculateDaysLeft(project.endDate);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      project.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.description,
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        SizedBox(height: 5),
                        RichText(
                          text: TextSpan(
                            text: 'Pozostało dni do końca projektu: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '$daysLeft',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${DateFormat('yyyy-MM-dd').format(project.startDate)} - ${DateFormat('yyyy-MM-dd').format(project.endDate)}',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Funkcja do obliczania dni do zakończenia projektu
  int _calculateDaysLeft(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;
    return difference >= 0 ? difference : 0;
  }
}
