import 'dart:convert';
import 'dart:math';
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

  /// Generate sample data for testing
  factory TrackerData.sampleData() {
    final random = Random(42); // Fixed seed for consistent data
    final now = DateTime.now();
    
    // Sample task names
    final taskNames = [
      'Exercise',
      'Read',
      'Meditate',
      'Drink Water',
      'Journal',
    ];
    
    final tasks = <Task>[];
    
    for (int i = 0; i < taskNames.length; i++) {
      final completions = <String, bool>{};
      
      // Generate completions for last 90 days
      for (int day = 0; day < 90; day++) {
        final date = DateTime(now.year, now.month, now.day - day);
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        // Different completion rates for different tasks
        // Exercise: ~70% completion
        // Read: ~80% completion
        // Meditate: ~60% completion
        // Drink Water: ~90% completion
        // Journal: ~50% completion
        final completionRates = [0.7, 0.8, 0.6, 0.9, 0.5];
        completions[key] = random.nextDouble() < completionRates[i];
      }
      
      tasks.add(Task(
        id: 'sample_$i',
        name: taskNames[i],
        createdAt: DateTime(now.year, now.month - 3, 1),
        completions: completions,
      ));
    }
    
    return TrackerData(tasks: tasks);
  }
}
