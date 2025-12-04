import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/task.dart';
import '../models/tracker_data.dart';
import '../theme/neo_brutalist_theme.dart';

class TaskGrid extends StatelessWidget {
  final TrackerData data;
  final AppSettings settings;
  final Function(String taskId, DateTime date) onToggleCompletion;
  final Function(String taskId) onRemoveTask;

  // Task row height (fixed vertical size)
  static const double _taskRowHeight = 42.0;
  static const double _cellSpacing = 4.0;
  static const double _taskNameWidth = 100.0;
  static const double _taskNameGap = 8.0;
  // Today's cell is square, others are narrower rectangles (same height)
  static const double _todayCellWidth = 42.0;

  const TaskGrid({
    super.key,
    required this.data,
    required this.settings,
    required this.onToggleCompletion,
    required this.onRemoveTask,
  });

  @override
  Widget build(BuildContext context) {
    // Get days in reverse order (newest first, for right-to-left display)
    final days = TrackerData.getLastNDays(
      settings.daysShownInTaskSection,
    ).reversed.toList();
    final today = DateTime.now();

    // Sort tasks: incomplete today first, then completed
    final sortedTasks = List<Task>.from(data.tasks);
    sortedTasks.sort((a, b) {
      final aCompleted = a.isCompletedOn(today);
      final bCompleted = b.isCompletedOn(today);
      if (aCompleted && !bCompleted) return 1;
      if (!aCompleted && bCompleted) return -1;
      return 0;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for cells
        // Total width - task name width - gap - today's square cell width - spacing
        final availableWidth =
            constraints.maxWidth -
            _taskNameWidth -
            _taskNameGap -
            _todayCellWidth -
            _cellSpacing;
        final numberOfOtherDays = settings.daysShownInTaskSection - 1;

        // Calculate cell width for non-today cells
        final totalSpacing = _cellSpacing * (numberOfOtherDays - 1);
        final otherCellWidth = numberOfOtherDays > 0
            ? (availableWidth - totalSpacing) / numberOfOtherDays
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels header (right to left - newest on right)
            _buildDayLabelsRow(days, today, otherCellWidth),
            const SizedBox(height: 8),
            // Task rows
            ...sortedTasks.map((task) {
              return _buildTaskRow(context, task, days, today, otherCellWidth);
            }),
          ],
        );
      },
    );
  }

  Widget _buildDayLabelsRow(
    List<DateTime> days,
    DateTime today,
    double otherCellWidth,
  ) {
    return Row(
      children: [
        // Empty space for task name column
        const SizedBox(width: _taskNameWidth),
        const SizedBox(width: _taskNameGap),
        // Day labels (already reversed)
        ...days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isLast = index == days.length - 1;
          final isToday = _isSameDay(day, today);
          final cellWidth = isToday ? _todayCellWidth : otherCellWidth;

          return Container(
            width: cellWidth,
            margin: EdgeInsets.only(right: isLast ? 0 : _cellSpacing),
            child: Center(
              child: Text(
                isToday ? 'Today' : day.day.toString(),
                style: TextStyle(
                  fontSize: isToday ? 10 : 10,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  color: isToday
                      ? AppTheme.completedColor
                      : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildTaskRow(
    BuildContext context,
    Task task,
    List<DateTime> days,
    DateTime today,
    double otherCellWidth,
  ) {
    final isCompletedToday = task.isCompletedOn(today);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Task name - tap to mark complete for today
          GestureDetector(
            onTap: () =>
                _showMarkCompleteDialog(context, task, today, isCompletedToday),
            onLongPress: () => _showDeleteDialog(context, task),
            child: Container(
              width: _taskNameWidth,
              height: _taskRowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompletedToday
                      ? AppTheme.completedColor
                      : Colors.grey.shade300,
                  width: isCompletedToday ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: isCompletedToday
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppTheme.completedColor,
                    decorationThickness: 2,
                    color: isCompletedToday
                        ? Colors.grey.shade500
                        : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: _taskNameGap),
          // Completion cells - fit exactly in available space (already reversed)
          ...days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isCompleted = task.isCompletedOn(day);
            final isLast = index == days.length - 1;
            final isToday = _isSameDay(day, today);

            // Today's cell is square, others are narrower rectangles (same height)
            final cellWidth = isToday ? _todayCellWidth : otherCellWidth;
            final cellHeight = _taskRowHeight;

            return Container(
              width: cellWidth,
              height: cellHeight,
              margin: EdgeInsets.only(right: isLast ? 0 : _cellSpacing),
              decoration: AppTheme.completedCellDecoration(isCompleted),
            );
          }),
        ],
      ),
    );
  }

  void _showMarkCompleteDialog(
    BuildContext context,
    Task task,
    DateTime today,
    bool isCompleted,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                isCompleted ? 'Mark Incomplete?' : 'Mark Complete?',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              InkWell(
                onTap: () {
                  onToggleCompletion(task.id, today);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: isCompleted
                          ? Colors.orange
                          : AppTheme.completedColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Divider(height: 1),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Delete Task?',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Delete "${task.name}" and all its history?',
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              InkWell(
                onTap: () {
                  onRemoveTask(task.id);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Divider(height: 1),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
