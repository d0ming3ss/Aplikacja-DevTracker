import 'package:flutter/material.dart';
import 'package:flutter_application_inz/pages/jira_detail_issue_page.dart';
import '../models/jira_issue.dart';
import '../services/jira_service.dart';

class JiraBoardIssuesPage extends StatefulWidget {
  final int boardId;

  JiraBoardIssuesPage({required this.boardId});

  @override
  _JiraBoardIssuesPageState createState() => _JiraBoardIssuesPageState();
}

class _JiraBoardIssuesPageState extends State<JiraBoardIssuesPage> {
  late Future<List<JiraIssue>> _issuesFuture;

  @override
  void initState() {
    super.initState();
    _issuesFuture = JiraService().getIssuesFromBoard(widget.boardId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informacje z tablicy JIRA'),
      ),
      body: FutureBuilder<List<JiraIssue>>(
        future: _issuesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }
          final issues = snapshot.data!;
          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return ListTile(
                title: Text(issue.summary ?? ' '),
                subtitle: Text('Klucz: ${issue.key}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IssueDetailPage(issue: issue),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../models/jira_issue.dart';
// import '../services/jira_service.dart';

// class JiraBoardIssuesPage extends StatefulWidget {
//   final int boardId;

//   JiraBoardIssuesPage({required this.boardId});

//   @override
//   _JiraBoardIssuesPageState createState() => _JiraBoardIssuesPageState();
// }

// class _JiraBoardIssuesPageState extends State<JiraBoardIssuesPage> {
//   late Future<List<JiraIssue>> _issuesFuture;

//   @override
//   void initState() {
//     super.initState();
//     _issuesFuture = JiraService().getIssuesFromBoard(widget.boardId);
//   }

//   Future<void> _changeIssueStatus(String issueKey) async {
//     String? newStatus = await showDialog<String>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Zmień status zadania'),
//           content: DropdownButtonFormField<String>(
//             items: ['TO DO', 'IN PROGRESS', 'DONE']
//                 .map((status) => DropdownMenuItem(
//                       value: status,
//                       child: Text(status),
//                     ))
//                 .toList(),
//             onChanged: (value) {},
//             decoration: InputDecoration(labelText: 'Wybierz status'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Anuluj'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Zmień'),
//               onPressed: () {
//                 // Zwróć wybrany status
//                 Navigator.of(context)
//                     .pop('IN PROGRESS'); // Na razie na sztywno dla przykładu
//               },
//             ),
//           ],
//         );
//       },
//     );

//     if (newStatus != null) {
//       // Dodajemy wskaźnik ładowania
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         },
//       );

//       try {
//         await JiraService().changeIssueStatus(issueKey, newStatus);
//         // Odśwież listę zgłoszeń po zmianie statusu
//         setState(() {
//           _issuesFuture = JiraService().getIssuesFromBoard(widget.boardId);
//         });
//       } catch (e) {
//         print('Błąd zmiany statusu: $e');
//         // Tutaj możesz dodać obsługę błędu, np. wyświetlić komunikat
//       } finally {
//         Navigator.of(context).pop(); // Usunięcie wskaźnika ładowania
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Zadania z tablicy JIRA'),
//       ),
//       body: FutureBuilder<List<JiraIssue>>(
//         future: _issuesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Błąd: ${snapshot.error}'));
//           }
//           final issues = snapshot.data!;
//           return ListView.builder(
//             itemCount: issues.length,
//             itemBuilder: (context, index) {
//               final issue = issues[index];
//               return ListTile(
//                 title:
//                     Text(issue.summary ?? 'Brak podsumowania'),
//                 subtitle: Text('Klucz: ${issue.key}'),
//                 trailing: IconButton(
//                   icon: Icon(Icons.edit),
//                   onPressed: () => _changeIssueStatus(issue.key),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
