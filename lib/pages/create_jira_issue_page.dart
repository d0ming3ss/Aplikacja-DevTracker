import 'package:flutter/material.dart';
import '../services/jira_service.dart';

class CreateJiraIssuePage extends StatefulWidget {
  @override
  _CreateJiraIssuePageState createState() => _CreateJiraIssuePageState();
}

class _CreateJiraIssuePageState extends State<CreateJiraIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _projectKeyController = TextEditingController();
  final _summaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  String selectedPriority = "Medium";
  String selectedStatus = "TO DO";
  // final List<String> priorities = [
  //   "Low",
  //   "Medium",
  //   "High"
  // ]; // Lista priorytetów
  // final List<String> statuses = [
  //   "TO DO",
  //   "IN PROGRESS",
  //   "DONE"
  // ]; // Lista statusów

  @override
  void dispose() {
    _projectKeyController.dispose();
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Future<void> _submitIssue() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isSubmitting = true;
  //     });
  //     try {
  //       final issue = await JiraService().createIssue(
  //         _projectKeyController.text,
  //         _summaryController.text,
  //         _descriptionController.text,
  //         selectedPriority,
  //         selectedStatus,
  //       );
  //       if (issue == 200 || issue == 201) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Zgłoszenie zostało prawidłowo utworzone!')),
  //         );
  //         Navigator.pop(context);
  //       } else {
  //         throw Exception('Nie udało się utworzyć zgłoszenia w JIRA');
  //       }
  //     } catch (e) {
  //       print('Błąd podczas tworzenia zgłoszenia: $e');

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Nie udało się utworzyć zgłoszenia w JIRA')),
  //       );
  //     } finally {
  //       setState(() {
  //         _isSubmitting = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _submitIssue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        final issue = await JiraService().createIssue(
          _projectKeyController.text,
          _summaryController.text,
          _descriptionController.text,
          selectedPriority,
          selectedStatus,
        );
        // Jeśli issue zostało utworzone, wyświetl komunikat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zgłoszenie zostało prawidłowo utworzone!')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Błąd podczas tworzenia zgłoszenia: $e');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się utworzyć zgłoszenia w JIRA')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Utwórz zgłoszenie w JIRA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isSubmitting
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _projectKeyController,
                      decoration: InputDecoration(labelText: 'Klucz projektu'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Proszę wprowadzić klucz projektu';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _summaryController,
                      decoration: InputDecoration(labelText: 'Podsumowanie'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Proszę wprowadzić podsumowanie';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Opis'),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Proszę wprowadzić opis';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Dodanie rozwijanego menu dla priorytetu
                    // DropdownButtonFormField<String>(
                    //   value: selectedPriority,
                    //   decoration: InputDecoration(labelText: 'Priorytet'),
                    //   items: priorities.map((String priority) {
                    //     return DropdownMenuItem<String>(
                    //       value: priority,
                    //       child: Text(priority),
                    //     );
                    //   }).toList(),
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       selectedPriority = newValue!;
                    //     });
                    //   },
                    //   validator: (value) =>
                    //       value == null ? 'Wybierz priorytet' : null,
                    // ),
                    SizedBox(height: 20),
                    // Dodanie rozwijanego menu dla statusu
                    // DropdownButtonFormField<String>(
                    //   value: selectedStatus,
                    //   decoration: InputDecoration(labelText: 'Status'),
                    //   items: statuses.map((String status) {
                    //     return DropdownMenuItem<String>(
                    //       value: status,
                    //       child: Text(status),
                    //     );
                    //   }).toList(),
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       selectedStatus = newValue!;
                    //     });
                    //   },
                    //   validator: (value) =>
                    //       value == null ? 'Wybierz status' : null,
                    // ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitIssue,
                      child: Text('Utwórz zgłoszenie'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
