// Rewritten file with clean neo-brutalist dialogs and sharper corners
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

  static const double _taskRowHeight = 42.0;
  static const double _cellSpacing = 4.0;
  static const double _taskNameWidth = 100.0;
  static const double _taskNameGap = 8.0;
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
    final days = TrackerData.getLastNDays(
      settings.daysShownInTaskSection,
    ).reversed.toList();
    final today = DateTime.now();

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
        final availableWidth =
            constraints.maxWidth -
            _taskNameWidth -
            _taskNameGap -
            _todayCellWidth -
            _cellSpacing;
        final numberOfOtherDays = settings.daysShownInTaskSection - 1;
        final totalSpacing = _cellSpacing * (numberOfOtherDays - 1);
        final otherCellWidth = numberOfOtherDays > 0
            ? (availableWidth - totalSpacing) / numberOfOtherDays
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDayLabelsRow(days, today, otherCellWidth),
            const SizedBox(height: 8),
            ...sortedTasks.map(
              (task) =>
                  _buildTaskRow(context, task, days, today, otherCellWidth),
            ),
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
        const SizedBox(width: _taskNameWidth),
        const SizedBox(width: _taskNameGap),
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
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
                borderRadius: BorderRadius.circular(1),
                border: Border.all(color: Colors.black54, width: 1.4),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(4, 4),
                    blurRadius: 0,
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    decoration: isCompletedToday
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppTheme.completedColor,
                    decorationThickness: 2,
                    color: isCompletedToday
                        ? Colors.grey.shade600
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
          ...days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isCompleted = task.isCompletedOn(day);
            final isLast = index == days.length - 1;
            final isToday = _isSameDay(day, today);

            final cellWidth = isToday ? _todayCellWidth : otherCellWidth;
            final cell = Container(
              width: cellWidth,
              height: _taskRowHeight,
              margin: EdgeInsets.only(right: isLast ? 0 : _cellSpacing),
              decoration: AppTheme.completedCellDecoration(isCompleted),
            );

            if (isToday) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    _showMarkCompleteDialog(context, task, day, isCompleted),
                child: cell,
              );
            }
            return cell;
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
          borderRadius: BorderRadius.circular(1),
          border: Border.all(color: Colors.black54, width: 1.4),
          boxShadow: const [
            BoxShadow(
              offset: Offset(4, 4),
              blurRadius: 0,
              color: Colors.black12,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    _NeoButton(
                      label: 'Edit Name',
                      background: Colors.white,
                      foreground: Colors.black,
                      icon: Icons.edit_outlined,
                      onTap: () {
                        Navigator.of(context).pop();
                        _showEditDialog(context, task);
                      },
                    ),
                    const SizedBox(height: 10),
                    _NeoButton(
                      label: 'Reorder Tasks',
                      background: Colors.white,
                      foreground: Colors.black,
                      icon: Icons.swap_vert,
                      onTap: () {
                        Navigator.of(context).pop();
                        _showReorderSheet(context);
                      },
                    ),
                    const SizedBox(height: 10),
                    _NeoButton(
                      label: 'Delete Task',
                      background: AppTheme.errorColor,
                      foreground: Colors.white,
                      icon: Icons.delete_outline,
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.of(context).pop();
                        _showDeleteDialog(context, task);
                      },
                    ),
                    const SizedBox(height: 10),
                    _NeoButton(
                      label: 'Cancel',
                      background: Colors.black,
                      foreground: Colors.white,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
            borderRadius: BorderRadius.circular(1),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                offset: Offset(6, 6),
                blurRadius: 0,
                color: Colors.black12,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Edit Task Name',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Task name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                        borderSide: BorderSide(color: Colors.black, width: 1.4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                        borderSide: BorderSide(color: Colors.black, width: 1.4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _NeoButton(
                          label: 'Save',
                          background: AppTheme.completedColor,
                          foreground: Colors.white,
                          onTap: () {
                            final newName = controller.text.trim();
                            if (newName.isNotEmpty && onRenameTask != null) {
                              onRenameTask!(task.id, newName);
                            }
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NeoButton(
                          label: 'Cancel',
                          background: Colors.black,
                          foreground: Colors.white,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
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
    DateTime day,
    bool isCompleted,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1),
          border: Border.all(color: Colors.black87, width: 1.6),
          boxShadow: const [
            BoxShadow(
              offset: Offset(4, 4),
              blurRadius: 0,
              color: Colors.black12,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  task.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _NeoButton(
                            label: isCompleted
                                ? 'Mark Incomplete'
                                : 'Mark Complete',
                            background: Colors.black,
                            foreground: Colors.white,
                            onTap: () {
                              onToggleCompletion(task.id, day);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _NeoButton(
                            label: 'Cancel',
                            background: Colors.black,
                            foreground: Colors.white,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ],
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
          borderRadius: BorderRadius.circular(1),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              offset: Offset(6, 6),
              blurRadius: 0,
              color: Colors.black12,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Delete "${task.name}" and all its history?',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _NeoButton(
                        label: 'Delete',
                        background: AppTheme.errorColor,
                        foreground: Colors.white,
                        onTap: () {
                          onRemoveTask(task.id);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _NeoButton(
                        label: 'Cancel',
                        background: Colors.black,
                        foreground: Colors.white,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
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
        borderRadius: BorderRadius.circular(1),
        border: Border.all(color: Colors.black54, width: 1.4),
        boxShadow: const [
          BoxShadow(offset: Offset(4, 4), blurRadius: 0, color: Colors.black12),
        ],
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
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Reorder Tasks',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
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
                    if (newIndex > oldIndex) newIndex -= 1;
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
                          color: AppTheme.completedColor.withAlpha(
                            (0.1 * 255).round(),
                          ),
                          borderRadius: BorderRadius.circular(1),
                          border: Border.all(color: Colors.black54, width: 1.2),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.completedColor,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        task.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_handle,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _NeoButton(
                    label: 'Save Order',
                    background: AppTheme.completedColor,
                    foreground: Colors.white,
                    onTap: () {
                      widget.onReorder?.call(_tasks);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 8),
                  _NeoButton(
                    label: 'Cancel',
                    background: Colors.black,
                    foreground: Colors.white,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeoButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  const _NeoButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(1),
          border: Border.all(color: Colors.black, width: 1.6),
          boxShadow: const [
            BoxShadow(
              offset: Offset(4, 4),
              blurRadius: 0,
              color: Colors.black12,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: iconColor ?? foreground),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
