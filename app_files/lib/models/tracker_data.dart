import 'dart:convert';
import 'task.dart';

class TrackerData {
  final List<Task> tasks;

  TrackerData({List<Task>? tasks}) : tasks = tasks ?? [];

  TrackerData copyWith({List<Task>? tasks}) {
    return TrackerData(tasks: tasks ?? List.from(this.tasks));
  }

  TrackerData addTask(Task task) {
    return copyWith(tasks: [...tasks, task]);
  }

  TrackerData removeTask(String taskId) {
    return copyWith(tasks: tasks.where((t) => t.id != taskId).toList());
  }

  TrackerData updateTask(Task updatedTask) {
    return copyWith(
      tasks: tasks
          .map((t) => t.id == updatedTask.id ? updatedTask : t)
          .toList(),
    );
  }

  TrackerData toggleTaskCompletion(String taskId, DateTime date) {
    return copyWith(
      tasks: tasks.map((t) {
        if (t.id == taskId) {
          return t.toggleCompletion(date);
        }
        return t;
      }).toList(),
    );
  }

  /// Calculate completion percentage for a specific date (0-100)
  double getCompletionPercentage(DateTime date) {
    if (tasks.isEmpty) return 0.0;

    int completed = 0;
    for (final task in tasks) {
      if (task.isCompletedOn(date)) {
        completed++;
      }
    }
    return (completed / tasks.length) * 100;
  }

  /// Calculate current streak (days with >70% completion)
  int calculateStreak() {
    int streak = 0;
    DateTime date = DateTime.now();

    // Start from yesterday to not break streak if today is incomplete
    date = DateTime(date.year, date.month, date.day - 1);

    while (true) {
      final percentage = getCompletionPercentage(date);
      if (percentage >= 70) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Also check today
    final todayPercentage = getCompletionPercentage(DateTime.now());
    if (todayPercentage >= 70) {
      streak++;
    }

    return streak;
  }

  /// Get last N days
  static List<DateTime> getLastNDays(int n) {
    final today = DateTime.now();
    return List.generate(n, (index) {
      return DateTime(today.year, today.month, today.day - (n - 1 - index));
    });
  }

  Map<String, dynamic> toJson() {
    return {'tasks': tasks.map((t) => t.toJson()).toList()};
  }

  factory TrackerData.fromJson(Map<String, dynamic> json) {
    final tasksList = (json['tasks'] as List)
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();
    return TrackerData(tasks: tasksList);
  }

  String toJsonString() => jsonEncode(toJson());

  factory TrackerData.fromJsonString(String jsonString) {
    return TrackerData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  factory TrackerData.empty() => TrackerData(tasks: []);
}
