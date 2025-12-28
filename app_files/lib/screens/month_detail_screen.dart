import 'package:flutter/material.dart';
import '../models/tracker_data.dart';
import '../models/app_settings.dart';
import '../theme/neo_brutalist_theme.dart';

class MonthDetailScreen extends StatefulWidget {
  final DateTime month;
  final TrackerData data;
  final AppSettings settings;
  final Function(String taskId, DateTime date)? onToggleCompletion;

  // Lighter green for history view
  static const Color historyCompletedColor = Color(0xFF86EFAC); // Lighter green

  const MonthDetailScreen({
    super.key,
    required this.month,
    required this.data,
    required this.settings,
    this.onToggleCompletion,
  });

  @override
  State<MonthDetailScreen> createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends State<MonthDetailScreen> {
  late TrackerData _data;

  static const double _taskNameWidth = 110.0;
  static const double _cellSize = 32.0;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
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

  List<DateTime> _getMonthDays() {
    final daysInMonth = DateTime(
      widget.month.year,
      widget.month.month + 1,
      0,
    ).day;
    final now = DateTime.now();
    final List<DateTime> days = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(widget.month.year, widget.month.month, day);
      // Only include past days and today
      if (!date.isAfter(now)) {
        days.add(date);
      }
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthName(widget.month.month);
    final year = widget.month.year;
    final monthDays = _getMonthDays();

    return Scaffold(
      appBar: AppBar(
        title: Text('$monthName $year'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _data.tasks.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary stats
                  _buildSummaryCard(context, monthDays),
                  const SizedBox(height: 16),
                  _buildEditableGrid(monthDays),
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
    int possibleCompletions = monthDays.length * _data.tasks.length;

    for (final task in _data.tasks) {
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
                  iconColor: MonthDetailScreen.historyCompletedColor,
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

  void _handleToggle(String taskId, DateTime date) {
    setState(() {
      _data = _data.toggleTaskCompletion(taskId, date);
    });
    widget.onToggleCompletion?.call(taskId, date);
  }

  Widget _buildEditableGrid(List<DateTime> days) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const SizedBox(width: _taskNameWidth, height: _cellSize),
                ...days.asMap().entries.map((entry) {
                  final day = entry.value;
                  return Container(
                    width: _cellSize,
                    height: _cellSize,
                    margin: EdgeInsets.only(
                      right: entry.key == days.length - 1 ? 0 : 4,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),
            // Task rows
            ..._data.tasks.map((task) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: _taskNameWidth,
                      height: _cellSize,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        task.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ...days.asMap().entries.map((entry) {
                      final day = entry.value;
                      final isFuture = day.isAfter(now);
                      final isCompleted = !isFuture && task.isCompletedOn(day);
                      final isToday =
                          day.year == now.year &&
                          day.month == now.month &&
                          day.day == now.day;

                      final color = isFuture
                          ? Colors.grey.shade200
                          : isCompleted
                          ? AppTheme.completedColor
                          : Colors.grey.shade300;

                      return GestureDetector(
                        onTap: isFuture
                            ? null
                            : () => _handleToggle(task.id, day),
                        child: Container(
                          width: _cellSize,
                          height: _cellSize,
                          margin: EdgeInsets.only(
                            right: entry.key == days.length - 1 ? 0 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isToday
                                  ? AppTheme.chartColor
                                  : Colors.transparent,
                              width: isToday ? 2 : 0,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
