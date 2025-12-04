import 'dart:convert';

class Task {
  final String id;
  final String name;
  final DateTime createdAt;
  final Map<String, bool> completions; // Key: 'yyyy-MM-dd', Value: completed

  Task({
    required this.id,
    required this.name,
    required this.createdAt,
    Map<String, bool>? completions,
  }) : completions = completions ?? {};

  Task copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Map<String, bool>? completions,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      completions: completions ?? Map.from(this.completions),
    );
  }

  bool isCompletedOn(DateTime date) {
    final key = _dateToKey(date);
    return completions[key] ?? false;
  }

  Task toggleCompletion(DateTime date) {
    final key = _dateToKey(date);
    final newCompletions = Map<String, bool>.from(completions);
    newCompletions[key] = !(completions[key] ?? false);
    return copyWith(completions: newCompletions);
  }

  static String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'completions': completions,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completions: Map<String, bool>.from(json['completions'] as Map),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Task.fromJsonString(String jsonString) {
    return Task.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
