import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectProgressPage extends StatefulWidget {
  @override
  _ProjectProgressPageState createState() => _ProjectProgressPageState();
}

class _ProjectProgressPageState extends State<ProjectProgressPage> {
  List projectsProgress = [];

  @override
  void initState() {
    super.initState();
    fetchProjectsProgress();
  }

  Future<void> fetchProjectsProgress() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/projects/progress'));

    if (response.statusCode == 200) {
      setState(() {
        projectsProgress = json.decode(response.body);
      });
    } else {
      throw Exception('Nie udało się załadować postępu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Postępy projektów")),
      body: Center(
        child: ListView.builder(
          itemCount: projectsProgress.length,
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          itemBuilder: (context, index) {
            final project = projectsProgress[index];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        project['projectName'],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Procent ukończenia: ${project['completionPercentage'].toStringAsFixed(2)}%",
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
