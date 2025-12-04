import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/task.dart';
import 'models/tracker_data.dart';
import 'models/app_settings.dart';
import 'services/storage_service.dart';
import 'theme/neo_brutalist_theme.dart';
import 'widgets/task_grid.dart';
import 'widgets/add_task_modal.dart';
import 'widgets/completion_chart.dart';
import 'screens/settings_screen.dart';
import 'screens/month_detail_screen.dart';
import 'screens/intro_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DailyTrackerApp());
}

class DailyTrackerApp extends StatefulWidget {
  const DailyTrackerApp({super.key});

  @override
  State<DailyTrackerApp> createState() => _DailyTrackerAppState();
}

class _DailyTrackerAppState extends State<DailyTrackerApp> {
  bool _isLoading = true;
  bool _hasSeenIntro = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    setState(() {
      _hasSeenIntro = hasSeenIntro;
      _isLoading = false;
    });
  }

  void _onIntroDone() {
    setState(() {
      _hasSeenIntro = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _hasSeenIntro
              ? const TrackerHomePage()
              : IntroScreen(onDone: _onIntroDone),
    );
  }
}

class TrackerHomePage extends StatefulWidget {
  const TrackerHomePage({super.key});

  @override
  State<TrackerHomePage> createState() => _TrackerHomePageState();
}

class _TrackerHomePageState extends State<TrackerHomePage> {
  TrackerData _data = TrackerData.empty();
  AppSettings _settings = AppSettings();
  bool _isLoading = true;
  int _currentIndex = 0;
  late ConfettiController _confettiController;
  bool _hasShownConfetti = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await StorageService.loadData();
    final settings = await StorageService.loadSettings();

    setState(() {
      _data = data;
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    await StorageService.saveData(_data);
  }

  Future<void> _saveSettings() async {
    await StorageService.saveSettings(_settings);
  }

  void _toggleCompletion(String taskId, DateTime date) {
    setState(() {
      _data = _data.toggleTaskCompletion(taskId, date);
    });
    _saveData();
  }

  void _addTask(String name) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    setState(() {
      _data = _data.addTask(task);
    });
    _saveData();
  }

  void _removeTask(String taskId) {
    setState(() {
      _data = _data.removeTask(taskId);
    });
    _saveData();
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    _saveSettings();
  }

  void _showAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskModal(onAddTask: _addTask),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          settings: _settings,
          onSettingsChanged: _updateSettings,
          onDataChanged: (newData) {
            setState(() {
              _data = newData;
            });
          },
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 1) {
      // Plus icon - show add task modal
      _showAddTaskModal();
    } else {
      setState(() {
        _currentIndex = index == 2 ? 1 : 0; // Map index 2 to history (index 1)
      });
    }
  }

  Widget _buildTodayProgressBar() {
    final today = DateTime.now();
    final percentage = _data.getCompletionPercentage(today);
    final progressValue = percentage / 100;

    // Determine colors based on percentage
    // 0-33% red, 33-66% yellow, 66-99% green, 100% gold
    Color progressColor;
    Color backgroundColor;
    Color textColor;

    if (percentage >= 100) {
      progressColor = const Color(0xFFFFD700); // Gold
      backgroundColor = const Color(0xFFFFF8DC); // Light gold
      textColor = const Color(0xFFB8860B); // Dark gold text
      // Trigger confetti if not shown yet
      if (!_hasShownConfetti) {
        _hasShownConfetti = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _confettiController.play();
        });
      }
    } else {
      _hasShownConfetti = false; // Reset when not 100%
      if (percentage >= 66) {
        progressColor = const Color(0xFF34C759); // Green
        backgroundColor = const Color(0xFFD1FAE5); // Light green
        textColor = progressValue > 0.5 ? Colors.white : Colors.green.shade800;
      } else if (percentage >= 33) {
        progressColor = const Color(0xFFFFCC00); // Yellow
        backgroundColor = const Color(0xFFFFF9E6); // Light yellow
        textColor = Colors.orange.shade900;
      } else {
        progressColor = const Color(0xFFFF3B30); // Red
        backgroundColor = const Color(0xFFFFE5E5); // Light red
        textColor = percentage > 15 ? Colors.white : Colors.red.shade800;
      }
    }

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Expanded(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  // Progress fill
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressValue.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Percentage text centered
                  Center(
                    child: Text(
                      '${percentage.round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: false,
            titleSpacing: 0,
            leadingWidth: 48,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(
                Icons.check_box_outlined,
                color: AppTheme.completedColor,
                size: 28,
              ),
            ),
            title: _currentIndex == 0
                ? Row(
                    children: [
                      const Spacer(),
                      const Text(
                        'Daily Progress:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      _buildTodayProgressBar(),
                      const Spacer(),
                    ],
                  )
                : const Text(
                    'History',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: _navigateToSettings,
              ),
            ],
          ),
          body: _currentIndex == 0 ? _buildHomeContent() : _buildHistoryContent(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex == 0 ? 0 : 2,
              onDestinationSelected: _onNavTap,
              height: 60,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, size: 32),
              selectedIcon: Icon(Icons.add_circle, size: 32),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'History',
            ),
          ],
        ),
      ),
        ),
        // Confetti widget for 100% completion celebration
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFFFFD700), // Gold
              Color(0xFFFFA500), // Orange
              Color(0xFFFF6347), // Tomato
              Color(0xFF98FB98), // Pale Green
              Color(0xFF87CEEB), // Sky Blue
              Color(0xFFDDA0DD), // Plum
            ],
            createParticlePath: (size) {
              final path = Path();
              path.addOval(Rect.fromCircle(center: Offset.zero, radius: size.width / 2));
              return path;
            },
          ),
        ),
        // Congrats message
        if (_confettiController.state == ConfettiControllerState.playing)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  '🎉 Congrats! 🎉',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Task Grid Section
          if (_data.tasks.isEmpty)
            _buildEmptyState()
          else
            TaskGrid(
              data: _data,
              settings: _settings,
              onToggleCompletion: _toggleCompletion,
              onRemoveTask: _removeTask,
            ),
          // Completion chart below tasks
          if (_data.tasks.isNotEmpty) ...[
            const SizedBox(height: 24),
            CompletionChart(data: _data, settings: _settings),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generate cards for the last 3 months
          ..._buildMonthCards(),
        ],
      ),
    );
  }

  List<Widget> _buildMonthCards() {
    final List<Widget> widgets = [];
    final now = DateTime.now();

    // Show last 3 months
    for (int monthOffset = 0; monthOffset < 3; monthOffset++) {
      final month = DateTime(now.year, now.month - monthOffset, 1);
      widgets.add(_buildMonthCard(month));
      widgets.add(const SizedBox(height: 16));
    }

    return widgets;
  }

  Widget _buildMonthCard(DateTime month) {
    final monthName = _getMonthName(month.month);
    final year = month.year;
    final stats = _calculateMonthStats(month);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MonthDetailScreen(
              month: month,
              data: _data,
              settings: _settings,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header with arrow indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$monthName $year',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.orange,
                    label: 'Max Streak',
                    value: '${stats['maxStreak']} days',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle,
                    iconColor: AppTheme.completedColor,
                    label: 'Goal Achieved',
                    value:
                        '${stats['goalsAchieved']}/${stats['totalDays']} days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Most completed goal
            if (stats['mostCompletedGoal'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Most Consistent Goal',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          Text(
                            stats['mostCompletedGoal'],
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${stats['mostCompletedCount']} days',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.completedColor,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Week day labels
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (day) => SizedBox(
                      width: AppTheme.cellSize + AppTheme.cellSpacing,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Calendar grid
            _buildCalendarGrid(month),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateMonthStats(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final now = DateTime.now();

    int maxStreak = 0;
    int currentStreak = 0;
    int goalsAchievedDays = 0;
    int totalDaysToCount = 0;

    Map<String, int> taskCompletionCounts = {};

    // Initialize task completion counts
    for (final task in _data.tasks) {
      taskCompletionCounts[task.name] = 0;
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);

      // Don't count future days
      if (date.isAfter(now)) break;

      totalDaysToCount++;
      final percentage = _data.getCompletionPercentage(date);

      if (percentage >= 70) {
        goalsAchievedDays++;
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }

      // Count completions per task
      for (final task in _data.tasks) {
        if (task.isCompletedOn(date)) {
          taskCompletionCounts[task.name] =
              (taskCompletionCounts[task.name] ?? 0) + 1;
        }
      }
    }

    // Find most completed goal
    String? mostCompletedGoal;
    int mostCompletedCount = 0;

    taskCompletionCounts.forEach((name, count) {
      if (count > mostCompletedCount) {
        mostCompletedCount = count;
        mostCompletedGoal = name;
      }
    });

    return {
      'maxStreak': maxStreak,
      'goalsAchieved': goalsAchievedDays,
      'totalDays': totalDaysToCount,
      'mostCompletedGoal': mostCompletedGoal,
      'mostCompletedCount': mostCompletedCount,
    };
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
              width: AppTheme.cellSize,
              height: AppTheme.cellSize,
              margin: EdgeInsets.only(right: AppTheme.cellSpacing),
            ),
          );
        } else {
          // Day cell with completion indicator
          final date = DateTime(month.year, month.month, currentDay);
          final percentage = _data.getCompletionPercentage(date);
          final isAboveThreshold = percentage >= 70;

          cells.add(
            Container(
              width: AppTheme.cellSize,
              height: AppTheme.cellSize,
              margin: EdgeInsets.only(right: AppTheme.cellSpacing),
              decoration: BoxDecoration(
                color: percentage > 0
                    ? (isAboveThreshold
                          ? AppTheme.completedColor
                          : AppTheme.completedColor.withAlpha(
                              (percentage / 100 * 255).toInt(),
                            ))
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
          currentDay++;
        }
      }

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: AppTheme.cellSpacing),
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

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No Tasks Yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
