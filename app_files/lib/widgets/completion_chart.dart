import 'package:flutter/material.dart';
import '../models/tracker_data.dart';
import '../theme/neo_brutalist_theme.dart';

class CompletionChart extends StatelessWidget {
  final TrackerData data;

  const CompletionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final days = TrackerData.getLastNDays(30);
    final percentages = days
        .map((day) => data.getCompletionPercentage(day))
        .toList();
    final maxHeight = 80.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeoBrutalistTheme.boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COMPLETION RATE', style: NeoBrutalistTheme.titleStyle),
          const SizedBox(height: 16),
          // Chart
          SizedBox(
            height: maxHeight + 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                SizedBox(
                  width: 30,
                  height: maxHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '100',
                        style: NeoBrutalistTheme.smallStyle.copyWith(
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        '50',
                        style: NeoBrutalistTheme.smallStyle.copyWith(
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        '0',
                        style: NeoBrutalistTheme.smallStyle.copyWith(
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Bars
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(percentages.length, (index) {
                        final percentage = percentages[index];
                        final barHeight = (percentage / 100) * maxHeight;
                        final day = days[index];

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: barHeight.clamp(2.0, maxHeight),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: percentage > 0
                                    ? NeoBrutalistTheme.chartColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: NeoBrutalistTheme.borderColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.day.toString(),
                              style: NeoBrutalistTheme.smallStyle.copyWith(
                                fontSize: 8,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // X-axis label
          Center(
            child: Text(
              'LAST 30 DAYS',
              style: NeoBrutalistTheme.smallStyle.copyWith(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
