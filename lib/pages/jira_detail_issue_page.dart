import 'package:flutter/material.dart';
import '../models/jira_issue.dart';

class IssueDetailPage extends StatelessWidget {
  final JiraIssue issue;

  IssueDetailPage({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Szczegóły zgłoszenia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Klucz: ${issue.key}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Podsumowanie: ${issue.summary ?? 'Brak podsumowania'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Opis: ${issue.description ?? 'Brak opisu'}',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
