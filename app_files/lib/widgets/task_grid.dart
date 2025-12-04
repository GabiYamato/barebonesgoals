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

  const TaskGrid({
    super.key,
    required this.data,
    required this.settings,
    required this.onToggleCompletion,
    required this.onRemoveTask,
  });

  @override
  Widget build(BuildContext context) {
    final days = TrackerData.getLastNDays(settings.daysShownInTaskSection);
    final today = DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width for cells
        // Total width - task name width - gap - padding for last cell spacing
        final availableWidth = constraints.maxWidth - _taskNameWidth - _taskNameGap;
        final numberOfDays = settings.daysShownInTaskSection;
        
        // Calculate cell width to fit exactly
        // (availableWidth - total spacing) / number of days
        final totalSpacing = _cellSpacing * (numberOfDays - 1);
        final cellWidth = (availableWidth - totalSpacing) / numberOfDays;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels header
            _buildDayLabelsRow(days, cellWidth),
            const SizedBox(height: 8),
            // Task rows
            ...data.tasks.map((task) => _buildTaskRow(context, task, days, today, cellWidth)),
          ],
        );
      },
    );
  }

  Widget _buildDayLabelsRow(List<DateTime> days, double cellWidth) {
    return Row(
      children: [
        // Empty space for task name column
        const SizedBox(width: _taskNameWidth),
        const SizedBox(width: _taskNameGap),
        // Day labels
        ...days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isLast = index == days.length - 1;
          
          return Container(
            width: cellWidth,
            margin: EdgeInsets.only(right: isLast ? 0 : _cellSpacing),
            child: Center(
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTaskRow(
    BuildContext context,
    Task task,
    List<DateTime> days,
    DateTime today,
    double cellWidth,
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isCompletedToday
                    ? AppTheme.completedColor.withAlpha(30)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: isCompletedToday
                    ? Border.all(color: AppTheme.completedColor, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    isCompletedToday
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 16,
                    color: isCompletedToday
                        ? AppTheme.completedColor
                        : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        decoration: isCompletedToday
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompletedToday ? Colors.grey.shade600 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: _taskNameGap),
          // Completion cells - fit exactly in available space
          ...days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isCompleted = task.isCompletedOn(day);
            final isLast = index == days.length - 1;
            
            return Container(
              width: cellWidth,
              height: _taskRowHeight,
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
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
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
                      color: isCompleted ? Colors.orange : AppTheme.completedColor,
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
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
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
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
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
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
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
