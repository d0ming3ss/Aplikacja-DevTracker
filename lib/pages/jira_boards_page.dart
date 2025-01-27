import 'package:flutter/material.dart';
import 'package:flutter_application_inz/pages/jira_board_issues_page.dart';
import '../models/jira_board.dart';
import '../services/jira_service.dart';

class JiraBoardsPage extends StatefulWidget {
  @override
  _JiraBoardsPageState createState() => _JiraBoardsPageState();
}

class _JiraBoardsPageState extends State<JiraBoardsPage> {
  late Future<List<JiraBoard>> _boardsFuture;

  @override
  void initState() {
    super.initState();
    _boardsFuture = JiraService().getBoards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tablice JIRA'),
      ),
      body: FutureBuilder<List<JiraBoard>>(
        future: _boardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Błąd: ${snapshot.error.toString()}'),
            );
          }
          final boards = snapshot.data!;
          return ListView.builder(
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];
              return ListTile(
                title: Text(board.name),
                subtitle: Text('ID: ${board.id}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          JiraBoardIssuesPage(boardId: board.id),
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
