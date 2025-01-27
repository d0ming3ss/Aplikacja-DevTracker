class JiraBoard {
  final int id;
  final String name;

  JiraBoard({required this.id, required this.name});

  factory JiraBoard.fromJson(Map<String, dynamic> json) {
    return JiraBoard(
      id: json['id'],
      name: json['name'],
    );
  }
}
