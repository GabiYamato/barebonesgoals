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
  int _currentPage = 0;
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

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPage1(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.completedColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: 56,
              color: AppTheme.completedColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to\nDaily Tracker',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Build streaks, track consistency, and make progress one day at a time.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              size: 44,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Pick starter tasks',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a few habits to get started.\nYou can always add more later.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          // Task chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 12,
            children: _sampleTasks.map((t) {
              final selected = _selected.contains(t);
              return GestureDetector(
                onTap: () => _toggle(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.completedColor
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppTheme.completedColor
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(Icons.check, size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        t,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.completedColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [_buildPage1(context), _buildPage2(context)],
              ),
            ),
            // Bottom section with indicator and button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  _buildPageIndicator(),
                  const SizedBox(height: 24),
                  // Button changes based on page
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _currentPage == 0
                          ? _goToNextPage
                          : _onStartPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.completedColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == 0 ? 'Next' : 'Get Started',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Skip option on page 1
                  if (_currentPage == 0) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _goToNextPage,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
