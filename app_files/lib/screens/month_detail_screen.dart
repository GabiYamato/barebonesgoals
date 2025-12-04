import 'package:flutter/material.dart';
import '../models/tracker_data.dart';
import '../models/app_settings.dart';
import '../theme/neo_brutalist_theme.dart';

class MonthDetailScreen extends StatelessWidget {
  final DateTime month;
  final TrackerData data;
  final AppSettings settings;

  // Lighter green for history view
  static const Color historyCompletedColor = Color(0xFF86EFAC); // Lighter green

  const MonthDetailScreen({
    super.key,
    required this.month,
    required this.data,
    required this.settings,
  });

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

  List<DateTime> _getMonthDays() {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final now = DateTime.now();
    final List<DateTime> days = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      // Only include past days and today
      if (!date.isAfter(now)) {
        days.add(date);
      }
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthName(month.month);
    final year = month.year;
    final monthDays = _getMonthDays();

    return Scaffold(
      appBar: AppBar(
        title: Text('$monthName $year'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: data.tasks.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary stats
                  _buildSummaryCard(context, monthDays),
                  const SizedBox(height: 16),
                  // Task grid for the month
                  ...data.tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTaskRow(context, task, monthDays),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text('No Tasks', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'No tasks were tracked this month',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<DateTime> monthDays) {
    int totalCompletions = 0;
    int possibleCompletions = monthDays.length * data.tasks.length;

    for (final task in data.tasks) {
      for (final day in monthDays) {
        if (task.isCompletedOn(day)) {
          totalCompletions++;
        }
      }
    }

    final percentage = possibleCompletions > 0
        ? (totalCompletions / possibleCompletions * 100).round()
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.calendar_month,
                  iconColor: AppTheme.chartColor,
                  label: 'Days Tracked',
                  value: '${monthDays.length}',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.check_circle,
                  iconColor: historyCompletedColor,
                  label: 'Completion',
                  value: '$percentage%',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.task_alt,
                  iconColor: Colors.orange,
                  label: 'Total Done',
                  value: '$totalCompletions',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTaskRow(BuildContext context, task, List<DateTime> monthDays) {
    // Calculate completion count for this task
    int completedCount = 0;
    for (final day in monthDays) {
      if (task.isCompletedOn(day)) {
        completedCount++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: historyCompletedColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$completedCount/${monthDays.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Completion grid for the month
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
              // Calculate cell size to fit all days in the month
              final totalSpacing = (daysInMonth - 1) * 3.0;
              final cellWidth = (availableWidth - totalSpacing) / daysInMonth;
              final cellSize = cellWidth.clamp(10.0, 20.0);

              return Wrap(
                spacing: 3,
                runSpacing: 3,
                children: List.generate(daysInMonth, (index) {
                  final day = DateTime(month.year, month.month, index + 1);
                  final now = DateTime.now();
                  final isFuture = day.isAfter(now);
                  final isCompleted = !isFuture && task.isCompletedOn(day);

                  return Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: isFuture
                          ? Colors.grey.shade100
                          : isCompleted
                          ? historyCompletedColor
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isFuture
                        ? null
                        : Center(
                            child: cellSize > 14
                                ? Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: isCompleted
                                          ? Colors.green.shade800
                                          : Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : null,
                          ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 8),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              Text(
                '${DateTime(month.year, month.month + 1, 0).day}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
