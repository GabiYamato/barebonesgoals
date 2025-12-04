import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/tracker_data.dart';
import '../theme/neo_brutalist_theme.dart';

class TaskGrid extends StatelessWidget {
  final TrackerData data;
  final Function(String taskId, DateTime date) onToggleCompletion;
  final Function(String taskId) onRemoveTask;

  const TaskGrid({
    super.key,
    required this.data,
    required this.onToggleCompletion,
    required this.onRemoveTask,
  });

  @override
  Widget build(BuildContext context) {
    final days = TrackerData.getLastNDays(30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels header
        _buildDayLabelsRow(days),
        const SizedBox(height: 4),
        // Task rows
        ...data.tasks.map((task) => _buildTaskRow(task, days)),
      ],
    );
  }

  Widget _buildDayLabelsRow(List<DateTime> days) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Empty space for task name column
        const SizedBox(width: 120),
        const SizedBox(width: 8),
        // Day labels
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: days.map((day) {
                return SizedBox(
                  width:
                      NeoBrutalistTheme.cellSize +
                      NeoBrutalistTheme.cellSpacing,
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: NeoBrutalistTheme.smallStyle.copyWith(
                        fontSize: 9,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskRow(Task task, List<DateTime> days) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Task name with remove button
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: NeoBrutalistTheme.boxDecoration,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    task.name.toUpperCase(),
                    style: NeoBrutalistTheme.smallStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () => onRemoveTask(task.id),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: NeoBrutalistTheme.backgroundColor,
                      border: Border.all(
                        color: NeoBrutalistTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: NeoBrutalistTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Completion cells
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: days.map((day) {
                  final isCompleted = task.isCompletedOn(day);
                  return GestureDetector(
                    onTap: () => onToggleCompletion(task.id, day),
                    child: Container(
                      width: NeoBrutalistTheme.cellSize,
                      height: NeoBrutalistTheme.cellSize,
                      margin: EdgeInsets.only(
                        right: NeoBrutalistTheme.cellSpacing,
                      ),
                      decoration: NeoBrutalistTheme.completedCellDecoration(
                        isCompleted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
