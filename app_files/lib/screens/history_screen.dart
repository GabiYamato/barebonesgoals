import 'package:flutter/material.dart';
import '../models/tracker_data.dart';
import '../theme/neo_brutalist_theme.dart';

class HistoryScreen extends StatelessWidget {
  final TrackerData data;

  const HistoryScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generate cards for the last 3 months
            ..._buildMonthCards(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMonthCards(BuildContext context) {
    final List<Widget> widgets = [];
    final now = DateTime.now();

    // Show last 3 months
    for (int monthOffset = 0; monthOffset < 3; monthOffset++) {
      final month = DateTime(now.year, now.month - monthOffset, 1);
      widgets.add(_buildMonthCard(context, month));
      widgets.add(const SizedBox(height: 16));
    }

    return widgets;
  }

  Widget _buildMonthCard(BuildContext context, DateTime month) {
    final monthName = _getMonthName(month.month);
    final year = month.year;
    final stats = _calculateMonthStats(month);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header
            Text(
              '$monthName $year',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    label: 'Max Streak',
                    value: '${stats['maxStreak']} days',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.check_circle,
                    iconColor: AppTheme.completedColor,
                    label: 'Goal Achieved',
                    value:
                        '${stats['goalsAchieved']}/${stats['totalDays']} days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Most completed goal
            if (stats['mostCompletedGoal'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Most Consistent Goal',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          Text(
                            stats['mostCompletedGoal'],
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${stats['mostCompletedCount']} days',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.completedColor,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Week day labels
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (day) => SizedBox(
                      width: AppTheme.cellSize + AppTheme.cellSpacing,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Calendar grid
            _buildCalendarGrid(month),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateMonthStats(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final now = DateTime.now();

    int maxStreak = 0;
    int currentStreak = 0;
    int goalsAchievedDays = 0;
    int totalDaysToCount = 0;

    Map<String, int> taskCompletionCounts = {};

    // Initialize task completion counts
    for (final task in data.tasks) {
      taskCompletionCounts[task.name] = 0;
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);

      // Don't count future days
      if (date.isAfter(now)) break;

      totalDaysToCount++;
      final percentage = data.getCompletionPercentage(date);

      if (percentage >= 70) {
        goalsAchievedDays++;
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }

      // Count completions per task
      for (final task in data.tasks) {
        if (task.isCompletedOn(date)) {
          taskCompletionCounts[task.name] =
              (taskCompletionCounts[task.name] ?? 0) + 1;
        }
      }
    }

    // Find most completed goal
    String? mostCompletedGoal;
    int mostCompletedCount = 0;

    taskCompletionCounts.forEach((name, count) {
      if (count > mostCompletedCount) {
        mostCompletedCount = count;
        mostCompletedGoal = name;
      }
    });

    return {
      'maxStreak': maxStreak,
      'goalsAchieved': goalsAchievedDays,
      'totalDays': totalDaysToCount,
      'mostCompletedGoal': mostCompletedGoal,
      'mostCompletedCount': mostCompletedCount,
    };
  }

  Widget _buildCalendarGrid(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;

    final List<Widget> rows = [];
    int currentDay = 1;

    // Build weeks
    for (int week = 0; week < 6 && currentDay <= daysInMonth; week++) {
      final List<Widget> cells = [];

      for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
        if ((week == 0 && dayOfWeek < firstWeekday) ||
            currentDay > daysInMonth) {
          // Empty cell
          cells.add(
            Container(
              width: AppTheme.cellSize,
              height: AppTheme.cellSize,
              margin: EdgeInsets.only(right: AppTheme.cellSpacing),
            ),
          );
        } else {
          // Day cell with completion indicator
          final date = DateTime(month.year, month.month, currentDay);
          final percentage = data.getCompletionPercentage(date);
          final isAboveThreshold = percentage >= 70;

          cells.add(
            Container(
              width: AppTheme.cellSize,
              height: AppTheme.cellSize,
              margin: EdgeInsets.only(right: AppTheme.cellSpacing),
              decoration: BoxDecoration(
                color: percentage > 0
                    ? (isAboveThreshold
                          ? AppTheme.completedColor
                          : AppTheme.completedColor.withAlpha(
                              (percentage / 100 * 255).toInt(),
                            ))
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
          currentDay++;
        }
      }

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: AppTheme.cellSpacing),
          child: Row(children: cells),
        ),
      );
    }

    return Column(children: rows);
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
