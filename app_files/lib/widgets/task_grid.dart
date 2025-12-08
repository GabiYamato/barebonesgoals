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
  final Function(String taskId, String newName)? onRenameTask;
  final Function(List<Task> newOrder)? onReorderTasks;

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
    this.onRenameTask,
    this.onReorderTasks,
  });

  @override
  Widget build(BuildContext context) {
    // Get days in reverse order (newest first, for right-to-left display)
    final days = TrackerData.getLastNDays(
      settings.daysShownInTaskSection,
    ).reversed.toList();
    final today = DateTime.now();

    // Sort tasks based on setting
    final sortedTasks = List<Task>.from(data.tasks);
    if (settings.sortCompletedToBottom) {
      sortedTasks.sort((a, b) {
        final aCompleted = a.isCompletedOn(today);
        final bCompleted = b.isCompletedOn(today);
        if (aCompleted && !bCompleted) return 1;
        if (!aCompleted && bCompleted) return -1;
        return 0;
      });
    }

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
            onLongPress: () => _showTaskOptionsMenu(context, task),
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

  void _showTaskOptionsMenu(BuildContext context, Task task) {
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
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
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
              // Edit option
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditDialog(context, task);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Name',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              // Reorder option
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _showReorderSheet(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_vert,
                        size: 20,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Reorder Tasks',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              // Delete option
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteDialog(context, task);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Delete Task',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ],
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

  void _showEditDialog(BuildContext context, Task task) {
    final controller = TextEditingController(text: task.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
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
                  'Edit Task Name',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Task name',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                InkWell(
                  onTap: () {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty && onRenameTask != null) {
                      onRenameTask!(task.id, newName);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.completedColor,
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
      ),
    );
  }

  void _showReorderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          _ReorderTasksSheet(tasks: data.tasks, onReorder: onReorderTasks),
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

class _ReorderTasksSheet extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task> newOrder)? onReorder;

  const _ReorderTasksSheet({required this.tasks, this.onReorder});

  @override
  State<_ReorderTasksSheet> createState() => _ReorderTasksSheetState();
}

class _ReorderTasksSheetState extends State<_ReorderTasksSheet> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Reorder Tasks',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Drag to reorder',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: _tasks.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _tasks.removeAt(oldIndex);
                    _tasks.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Container(
                    key: ValueKey(task.id),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.completedColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.completedColor,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        task.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_handle,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            InkWell(
              onTap: () {
                widget.onReorder?.call(_tasks);
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Save Order',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.completedColor,
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
    );
  }
}
