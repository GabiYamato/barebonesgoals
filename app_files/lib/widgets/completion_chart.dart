import 'dart:math';

import 'package:flutter/material.dart';
import '../models/tracker_data.dart';
import '../models/app_settings.dart';
import '../theme/neo_brutalist_theme.dart';

const double _chartSlotWidth = 22.0;

class CompletionChart extends StatefulWidget {
  final TrackerData data;
  final AppSettings settings;

  const CompletionChart({
    super.key,
    required this.data,
    required this.settings,
  });

  @override
  State<CompletionChart> createState() => _CompletionChartState();
}

class _CompletionChartState extends State<CompletionChart> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to end (newest day) after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysCount = min(14, widget.settings.daysShownInGraph);
    final days = TrackerData.getLastNDays(daysCount);
    final percentages = days
        .map((day) => widget.data.getCompletionPercentage(day))
        .toList();
    const double chartHeight = 140.0;
    const double xAxisHeight = 20.0;
    final streak = widget.data.calculateStreak();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppTheme.chartColor),
              const SizedBox(width: 8),
              Text(
                'Completion Rate',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              // Streak indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$streak',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart with Y-axis
          SizedBox(
            height: chartHeight + xAxisHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Y-axis labels - properly aligned to chart area
                SizedBox(
                  width: 40,
                  height: chartHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '50%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '0%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Chart content with clipping - scrolled to end
                Expanded(
                  child: ClipRect(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final content = _buildChartContent(
                          days,
                          percentages,
                          chartHeight,
                          constraints.maxWidth,
                        );

                        return SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: Center(child: content),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Last $daysCount days',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent(
    List<DateTime> days,
    List<double> percentages,
    double chartHeight,
    double availableWidth,
  ) {
    switch (widget.settings.graphType) {
      case GraphType.bar:
        return _buildBarChart(days, percentages, chartHeight, availableWidth);
      case GraphType.line:
        return _buildLineChart(days, percentages, chartHeight, availableWidth);
      case GraphType.dots:
        return _buildDotChart(days, percentages, chartHeight, availableWidth);
      case GraphType.area:
        return _buildAreaChart(days, percentages, chartHeight, availableWidth);
      case GraphType.stepped:
        return _buildSteppedChart(
          days,
          percentages,
          chartHeight,
          availableWidth,
        );
    }
  }

  Widget _buildBarChart(
    List<DateTime> days,
    List<double> percentages,
    double chartHeight,
    double availableWidth,
  ) {
    const double barWidth = 18.0;
    final contentWidth = max(
      percentages.length * _chartSlotWidth,
      availableWidth - 40,
    );

    return SizedBox(
      width: contentWidth,
      height: chartHeight + 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(percentages.length, (index) {
          final percentage = percentages[index];
          final barHeight = (percentage / 100) * chartHeight;
          final day = days[index];

          return SizedBox(
            width: _chartSlotWidth,
            child: Column(
              children: [
                // Chart area
                SizedBox(
                  height: chartHeight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: barWidth,
                      height: barHeight.clamp(2.0, chartHeight),
                      decoration: BoxDecoration(
                        color: percentage > 0
                            ? AppTheme.chartColor
                            : Colors.grey.shade300,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                // X-axis label
                const SizedBox(height: 4),
                Text(
                  day.day.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLineChart(
    List<DateTime> days,
    List<double> percentages,
    double chartHeight,
    double availableWidth,
  ) {
    final contentWidth = max(
      percentages.length * _chartSlotWidth,
      availableWidth - 40,
    );

    return SizedBox(
      width: contentWidth,
      height: chartHeight + 20,
      child: Column(
        children: [
          // Chart area
          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              size: Size(percentages.length * _chartSlotWidth, chartHeight),
              painter: LineChartPainter(
                percentages: percentages,
                maxHeight: chartHeight,
              ),
            ),
          ),
          // X-axis labels
          const SizedBox(height: 4),
          Row(
            children: days
                .map(
                  (day) => SizedBox(
                    width: _chartSlotWidth,
                    child: Text(
                      day.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDotChart(
    List<DateTime> days,
    List<double> percentages,
    double chartHeight,
    double availableWidth,
  ) {
    final contentWidth = max(
      percentages.length * _chartSlotWidth,
      availableWidth - 40,
    );

    return SizedBox(
      width: contentWidth,
      height: chartHeight + 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(percentages.length, (index) {
          final percentage = percentages[index];
          final dotY = chartHeight - (percentage / 100) * chartHeight - 4;
          final day = days[index];

          return SizedBox(
            width: _chartSlotWidth,
            child: Column(
              children: [
                // Chart area with dot
                SizedBox(
                  height: chartHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        top: dotY.clamp(0.0, chartHeight - 8),
                        left: (_chartSlotWidth - 8) / 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: percentage > 0
                                ? AppTheme.chartColor
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // X-axis label
                const SizedBox(height: 4),
                Text(
                  day.day.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAreaChart(
    List<DateTime> days,
    List<double> percentages,
    double chartHeight,
    double availableWidth,
  ) {
    final contentWidth = max(
      percentages.length * _chartSlotWidth,
      availableWidth - 40,
    );

    return SizedBox(
      width: contentWidth,
      height: chartHeight + 20,
      child: Column(
        children: [
          // Chart area
          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              size: Size(percentages.length * _chartSlotWidth, chartHeight),
              painter: AreaChartPainter(
                percentages: percentages,
                maxHeight: chartHeight,
              ),
            ),
          ),
          // X-axis labels
          const SizedBox(height: 4),
          Row(
            children: days
                .map(
                  (day) => SizedBox(
                    width: _chartSlotWidth,
                    child: Text(
                      day.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSteppedChart(
    List<DateTime> days,
    List<double> percentages,
    double chartHeight,
    double availableWidth,
  ) {
    final contentWidth = max(
      percentages.length * _chartSlotWidth,
      availableWidth - 40,
    );

    return SizedBox(
      width: contentWidth,
      height: chartHeight + 20,
      child: Column(
        children: [
          // Chart area
          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              size: Size(percentages.length * _chartSlotWidth, chartHeight),
              painter: SteppedChartPainter(
                percentages: percentages,
                maxHeight: chartHeight,
              ),
            ),
          ),
          // X-axis labels
          const SizedBox(height: 4),
          Row(
            children: days
                .map(
                  (day) => SizedBox(
                    width: _chartSlotWidth,
                    child: Text(
                      day.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> percentages;
  final double maxHeight;

  LineChartPainter({required this.percentages, required this.maxHeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (percentages.isEmpty) return;

    final paint = Paint()
      ..color = AppTheme.chartColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final path = Path();
    const stepX = _chartSlotWidth;

    for (int i = 0; i < percentages.length; i++) {
      final x = i * stepX + stepX / 2;
      final y = maxHeight - (percentages[i] / 100) * maxHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots on points
    final dotPaint = Paint()
      ..color = AppTheme.chartColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < percentages.length; i++) {
      final x = i * stepX + stepX / 2;
      final y = maxHeight - (percentages[i] / 100) * maxHeight;
      canvas.drawCircle(Offset(x, y), 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AreaChartPainter extends CustomPainter {
  final List<double> percentages;
  final double maxHeight;

  AreaChartPainter({required this.percentages, required this.maxHeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (percentages.isEmpty) return;

    const stepX = _chartSlotWidth;

    // Area fill
    final areaPath = Path();
    areaPath.moveTo(stepX / 2, maxHeight);

    for (int i = 0; i < percentages.length; i++) {
      final x = i * stepX + stepX / 2;
      final y = maxHeight - (percentages[i] / 100) * maxHeight;
      areaPath.lineTo(x, y);
    }

    areaPath.lineTo((percentages.length - 1) * stepX + stepX / 2, maxHeight);
    areaPath.close();

    final areaPaint = Paint()
      ..color = AppTheme.chartColor.withAlpha(50)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);

    // Line on top
    final linePaint = Paint()
      ..color = AppTheme.chartColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    for (int i = 0; i < percentages.length; i++) {
      final x = i * stepX + stepX / 2;
      final y = maxHeight - (percentages[i] / 100) * maxHeight;

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SteppedChartPainter extends CustomPainter {
  final List<double> percentages;
  final double maxHeight;

  SteppedChartPainter({required this.percentages, required this.maxHeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (percentages.isEmpty) return;

    final paint = Paint()
      ..color = AppTheme.chartColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final path = Path();
    const stepX = _chartSlotWidth;

    for (int i = 0; i < percentages.length; i++) {
      final x = i * stepX;
      final y = maxHeight - (percentages[i] / 100) * maxHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Horizontal then vertical (stepped)
        final prevY = maxHeight - (percentages[i - 1] / 100) * maxHeight;
        path.lineTo(x, prevY);
        path.lineTo(x, y);
      }
      path.lineTo(x + stepX, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
