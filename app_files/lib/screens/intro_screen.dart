import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';
import '../services/storage_service.dart';
import '../models/task.dart';
import '../models/tracker_data.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback? onDone;

  const IntroScreen({super.key, this.onDone});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  final List<String> _sampleTasks = [
    'GYM',
    '8k Steps',
    'Leetcode',
    'Skill',
    'Creative',
    'Coding',
  ];
  final Set<String> _selected = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggle(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
  }

  Future<void> _onStartPressed() async {
    // Persist selected sample tasks
    final current = await StorageService.loadData();
    TrackerData newData = current;

    for (final name in _selected) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString() + name,
        name: name,
        createdAt: DateTime.now(),
      );
      newData = newData.addTask(task);
    }

    await StorageService.saveData(newData);
    await StorageService.setHasSeenIntro(true);

    // Notify parent
    widget.onDone?.call();

    // Pop back to main (home will update based on flag)
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  Widget _buildPage1(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Text(
          'Welcome to Daily Tracker',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Build streaks, track consistency, and make progress one day at a time.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPage2(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pick a few starter tasks',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: _sampleTasks.map((t) {
            final selected = _selected.contains(t);
            return FilterChip(
              label: Text(t),
              selected: selected,
              checkmarkColor: Colors.white,
              selectedColor: AppTheme.completedColor,
              onSelected: (_) => _toggle(t),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Text(
          'Tap to select tasks you want to start with. You can edit them later.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        // Start button
        SizedBox(
          width: 140,
          child: ElevatedButton(
            onPressed: _onStartPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.completedColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6), // less rounded
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Start.'), // single-line text
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [_buildPage1(context), _buildPage2(context)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: const Text('Back'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                        child: const Text('Next'),
                      ),
                    ],
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
