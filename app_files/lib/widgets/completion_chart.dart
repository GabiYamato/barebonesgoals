import 'package:flutter/material.dart';
import '../models/tracker_data.dart';
import '../models/app_settings.dart';
import '../theme/neo_brutalist_theme.dart';

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
    final days = TrackerData.getLastNDays(widget.settings.daysShownInGraph);
    final percentages = days
        .map((day) => widget.data.getCompletionPercentage(day))
        .toList();
    const double chartHeight = 100.0;
    const double xAxisHeight = 20.0;
    final streak = widget.data.calculateStreak();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completion Rate',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Streak indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
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
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '50%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '0%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chart content with clipping - scrolled to end
                  Expanded(
                    child: ClipRect(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: _buildChartContent(
                          days,
                          percentages,
                          chartHeight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Last ${widget.settings.daysShownInGraph} days',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent(
    List<DateTime> days,
    List<double> percentages,
    double chartHeight,
  ) {
    switch (widget.settings.graphType) {
      case GraphType.bar:
        return _buildBarChart(days, percentages, chartHeight);
      case GraphType.line:
        return _buildLineChart(days, percentages, chartHeight);
      case GraphType.dots:
        return _buildDotChart(days, percentages, chartHeight);
      case GraphType.area:
        return _buildAreaChart(days, percentages, chartHeight);
      case GraphType.stepped:
        return _buildSteppedChart(days, percentages, chartHeight);
    }
  }

  Widget _buildBarChart(
    List<DateTime> days,
    List<double> percentages,
    double chartHeight,
  ) {
    return SizedBox(
      height: chartHeight + 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(percentages.length, (index) {
          final percentage = percentages[index];
          final barHeight = (percentage / 100) * chartHeight;
          final day = days[index];

          return SizedBox(
            width: 18,
            child: Column(
              children: [
                // Chart area
                SizedBox(
                  height: chartHeight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 14,
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
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
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
  ) {
    return SizedBox(
      width: percentages.length * 18.0,
      height: chartHeight + 20,
      child: Column(
        children: [
          // Chart area
          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              size: Size(percentages.length * 18.0, chartHeight),
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
                    width: 18,
                    child: Text(
                      day.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
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
  ) {
    return SizedBox(
      height: chartHeight + 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(percentages.length, (index) {
          final percentage = percentages[index];
          final dotY = chartHeight - (percentage / 100) * chartHeight - 4;
          final day = days[index];

          return SizedBox(
            width: 18,
            child: Column(
              children: [
                // Chart area with dot
                SizedBox(
                  height: chartHeight,
                  child: Stack(
                    children: [
                      Positioned(
                        top: dotY.clamp(0.0, chartHeight - 8),
                        left: 5,
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
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
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
  ) {
    return SizedBox(
      width: percentages.length * 18.0,
      height: chartHeight + 20,
      child: Column(
        children: [
          // Chart area
          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              size: Size(percentages.length * 18.0, chartHeight),
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
                    width: 18,
                    child: Text(
                      day.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
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
  ) {
    return SizedBox(
      width: percentages.length * 18.0,
      height: chartHeight + 20,
      child: Column(
        children: [
          // Chart area
          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              size: Size(percentages.length * 18.0, chartHeight),
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
                    width: 18,
                    child: Text(
                      day.day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
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
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const stepX = 18.0;

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
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
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

    const stepX = 18.0;

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
      ..strokeWidth = 2
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
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const stepX = 18.0;

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
