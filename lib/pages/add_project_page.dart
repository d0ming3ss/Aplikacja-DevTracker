import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({Key? key}) : super(key: key);

  @override
  _AddProjectPageState createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  bool _nameError = false; // Zmienna do zarządzania błędem nazwy
  bool _descriptionError = false; // Zmienna do zarządzania błędem opisu

  Future<void> addProject() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;

    setState(() {
      _nameError = name.isEmpty;
      _descriptionError = description.isEmpty;
    });

    if (name.isNotEmpty &&
        description.isNotEmpty &&
        _startDate != null &&
        _endDate != null) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8080/projects'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'description': description,
            'startDate': _startDate!.toIso8601String(),
            'endDate': _endDate!.toIso8601String(),
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Projekt dodany pomyślnie!"),
          ));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Wystąpił błąd podczas dodawania projektu: ${response.reasonPhrase}"),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Wystąpił błąd: $e"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Proszę wprowadzić wszystkie dane."),
      ));
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dodaj Nowy Projekt"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nazwa projektu',
                errorText:
                    _nameError ? 'Nazwa projektu nie może być pusta' : null,
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Opis projektu',
                errorText: _descriptionError
                    ? 'Opis projektu nie może być pusty'
                    : null,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _startDate == null
                        ? 'Wybierz datę rozpoczęcia'
                        : 'Data rozpoczęcia: ${_startDate!.toLocal()}'
                            .split(' ')[0],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectStartDate(context),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _endDate == null
                        ? 'Wybierz datę zakończenia'
                        : 'Data zakończenia: ${_endDate!.toLocal()}'
                            .split(' ')[0],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectEndDate(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addProject,
              child: Text("Dodaj Projekt"),
            ),
          ],
        ),
      ),
    );
  }
}
