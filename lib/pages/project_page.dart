import 'package:flutter/material.dart';
import 'package:flutter_application_inz/pages/add_project_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'project_detail_page.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<dynamic> _projects = [];

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
        setState(() {
          _projects = jsonDecode(response.body);
        });
      } else {
        print('Błąd podczas pobierania projektów: ${response.statusCode}');
      }
    } catch (e) {
      print('Błąd: $e');
    }
  }

  void navigateToAddProject() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProjectPage(),
      ),
    );
  }

  void navigateToProjectDetail(dynamic project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailPage(project: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projekty"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: navigateToAddProject,
          ),
        ],
      ),
      body: _projects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return ListTile(
                  title: Text(
                    project['name'],
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  subtitle: Text(
                    "${project['description']} - Data rozpoczęcia: ${project['startDate']}, Data zakończenia: ${project['endDate']}",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                  onTap: () => navigateToProjectDetail(project),
                );
              },
            ),
    );
  }
}
