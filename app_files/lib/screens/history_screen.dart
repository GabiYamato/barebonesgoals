import 'package:flutter/material.dart';
import '../models/tracker_data.dart';
import '../theme/neo_brutalist_theme.dart';

class HistoryScreen extends StatelessWidget {
  final TrackerData data;

  const HistoryScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalistTheme.backgroundColor,
      body: Column(
        children: [
          // Top bar
          _buildTopBar(context),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Generate grids for the last 3 months
                  ..._buildMonthGrids(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: NeoBrutalistTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalistTheme.borderColor,
            width: NeoBrutalistTheme.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: NeoBrutalistTheme.boxDecoration,
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: NeoBrutalistTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text('HISTORY', style: NeoBrutalistTheme.headingStyle),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMonthGrids() {
    final List<Widget> widgets = [];
    final now = DateTime.now();

    // Show last 3 months
    for (int monthOffset = 0; monthOffset < 3; monthOffset++) {
      final month = DateTime(now.year, now.month - monthOffset, 1);
      widgets.add(_buildMonthSection(month));
      widgets.add(const SizedBox(height: 24));
    }

    return widgets;
  }

  Widget _buildMonthSection(DateTime month) {
    final monthName = _getMonthName(month.month);
    final year = month.year;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeoBrutalistTheme.boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$monthName $year'.toUpperCase(),
            style: NeoBrutalistTheme.titleStyle,
          ),
          const SizedBox(height: 12),
          // Week day labels
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => SizedBox(
                    width:
                        NeoBrutalistTheme.cellSize +
                        NeoBrutalistTheme.cellSpacing,
                    child: Center(
                      child: Text(
                        day,
                        style: NeoBrutalistTheme.smallStyle.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid (7 columns for days of week)
          _buildCalendarGrid(month),
        ],
      ),
    );
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
              width: NeoBrutalistTheme.cellSize,
              height: NeoBrutalistTheme.cellSize,
              margin: EdgeInsets.only(right: NeoBrutalistTheme.cellSpacing),
            ),
          );
        } else {
          // Day cell with completion indicator
          final date = DateTime(month.year, month.month, currentDay);
          final percentage = data.getCompletionPercentage(date);
          final isAboveThreshold = percentage >= 70;

          cells.add(
            Container(
              width: NeoBrutalistTheme.cellSize,
              height: NeoBrutalistTheme.cellSize,
              margin: EdgeInsets.only(right: NeoBrutalistTheme.cellSpacing),
              decoration: BoxDecoration(
                color: percentage > 0
                    ? (isAboveThreshold
                          ? NeoBrutalistTheme.completedColor
                          : NeoBrutalistTheme.completedColor.withAlpha(
                              (percentage / 100 * 255).toInt(),
                            ))
                    : NeoBrutalistTheme.backgroundColor,
                border: Border.all(
                  color: NeoBrutalistTheme.borderColor,
                  width: NeoBrutalistTheme.thinBorderWidth,
                ),
              ),
            ),
          );
          currentDay++;
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: NeoBrutalistTheme.cellSpacing),
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
