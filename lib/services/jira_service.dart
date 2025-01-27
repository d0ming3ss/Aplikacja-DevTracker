import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/jira_board.dart';
import '../models/jira_issue.dart';

class JiraService {
  final String baseUrl = 'http://localhost:8080/jira';

  Future<List<JiraBoard>> getBoards() async {
    final response = await http.get(Uri.parse('$baseUrl/boards'));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('values')) {
        List<dynamic> boardsJson = jsonResponse['values'];
        return boardsJson.map((json) => JiraBoard.fromJson(json)).toList();
      } else if (jsonResponse is List) {
        return jsonResponse.map((json) => JiraBoard.fromJson(json)).toList();
      } else {
        throw Exception('Nieoczekiwany format odpowiedzi');
      }
    } else {
      throw Exception('Nie udało się pobrać tablic JIRA');
    }
  }

  Future<List<JiraIssue>> getIssuesFromBoard(int boardId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/boards/$boardId/issues'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('issues')) {
        List<dynamic> issuesJson = jsonResponse['issues'];
        return issuesJson.map((json) => JiraIssue.fromJson(json)).toList();
      } else {
        throw Exception('Odpowiedź z serwera nie zawiera listy zgłoszeń');
      }
    } else {
      throw Exception('Nie udało się pobrać zadań z tablicy JIRA');
    }
  }

  Future<JiraIssue> createIssue(
      String projectKey,
      String summary,
      String description,
      String selectedPriority,
      String selectedStatus) async {
    final response = await http.post(
      Uri.parse('$baseUrl/issues'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'projectKey': projectKey,
        'summary': summary,
        'description': description,
        'priority': {
          'name': selectedPriority,
        },
        'selectedStatus': selectedStatus,
      }),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return JiraIssue.fromJson(jsonResponse);
      } catch (e) {
        print('Błąd dekodowania JSON: $e');
        throw Exception('Nie udało się utworzyć zgłoszenia w JIRA');
      }
    } else {
      print('Błąd w odpowiedzi: ${response.body}');
      throw Exception(
          'Nie udało się utworzyć zgłoszenia w JIRA: ${response.statusCode}');
    }
  }

  // Zmiana statusu zgłoszenia
  // Future<void> changeIssueStatus(String issueKey, String newStatus) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/issues/$issueKey/status'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'newStatus': newStatus}),
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception('Nie udało się zmienić statusu zgłoszenia.');
  //     }
  //   } catch (e) {
  //     print('Błąd zmiany statusu: $e');
  //     throw Exception('Błąd połączenia z serwerem.');
  //   }
  // }
}
