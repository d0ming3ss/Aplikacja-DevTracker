// class JiraIssue {
//   final String key;
//   final String summary;

//   JiraIssue({required this.key, required this.summary});

//   factory JiraIssue.fromJson(Map<String, dynamic> json) {
//     return JiraIssue(
//       key: json['key'],
//       summary: json['fields']['summary'],
//     );
//   }
// }

// class JiraIssue {
//   final String key;
//   final String? summary;

//   JiraIssue({required this.key, this.summary});

//   factory JiraIssue.fromJson(Map<String, dynamic> json) {
//     return JiraIssue(
//       key: json['key'],
//       summary: json.containsKey('fields') ? json['fields']['summary'] : null,
//     );
//   }
// }

class JiraIssue {
  final String key;
  final String? summary; // Możemy zostawić opcjonalne
  final String? description; // Dodajemy pole do opisu

  JiraIssue({required this.key, this.summary, this.description});

  factory JiraIssue.fromJson(Map<String, dynamic> json) {
    return JiraIssue(
      key: json['key'],
      summary: json.containsKey('fields') ? json['fields']['summary'] : null,
      description:
          json.containsKey('fields') ? json['fields']['description'] : null,
    );
  }
}
