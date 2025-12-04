import 'package:flutter/material.dart';
import 'models/task.dart';
import 'models/tracker_data.dart';
import 'services/storage_service.dart';
import 'theme/neo_brutalist_theme.dart';
import 'widgets/top_bar.dart';
import 'widgets/task_grid.dart';
import 'widgets/add_task_modal.dart';
import 'widgets/completion_chart.dart';
import 'screens/history_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DailyTrackerApp());
}

class DailyTrackerApp extends StatelessWidget {
  const DailyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      debugShowCheckedModeBanner: false,
      theme: NeoBrutalistTheme.themeData,
      home: const TrackerHomePage(),
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await StorageService.loadData();
    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    await StorageService.saveData(_data);
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

  void _showAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTaskModal(onAddTask: _addTask),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => HistoryScreen(data: _data)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: NeoBrutalistTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: NeoBrutalistTheme.primaryColor,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NeoBrutalistTheme.backgroundColor,
      body: Column(
        children: [
          // Top Bar
          TopBar(streak: _data.calculateStreak()),
          // Main content
          Expanded(
            child: SingleChildScrollView(
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
                      onToggleCompletion: _toggleCompletion,
                      onRemoveTask: _removeTask,
                    ),
                  const SizedBox(height: 16),
                  // Action Buttons Row
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  // Completion Chart
                  if (_data.tasks.isNotEmpty) CompletionChart(data: _data),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: NeoBrutalistTheme.boxDecoration,
      child: Column(
        children: [
          const Icon(
            Icons.check_box_outline_blank,
            size: 48,
            color: NeoBrutalistTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text('NO TASKS YET', style: NeoBrutalistTheme.titleStyle),
          const SizedBox(height: 8),
          Text(
            'Add your first task to start tracking',
            style: NeoBrutalistTheme.bodyStyle.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Add Task Button
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _showAddTaskModal,
              style: NeoBrutalistTheme.buttonStyleFlat,
              child: const Text(
                'ADD TASK',
                style: NeoBrutalistTheme.buttonStyle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // History Button
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _navigateToHistory,
            style: NeoBrutalistTheme.buttonStyleFlat,
            child: const Text('HISTORY', style: NeoBrutalistTheme.buttonStyle),
          ),
        ),
      ],
    );
  }
}
