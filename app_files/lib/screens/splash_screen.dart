import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';
import 'intro_screen.dart';

class SplashScreen extends StatelessWidget {
  final VoidCallback? onIntroDone;
  const SplashScreen({super.key, this.onIntroDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 96, color: AppTheme.completedColor),
              const SizedBox(height: 24),
              Text(
                'Daily Tracker',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track small habits consistently',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => IntroScreen(onDone: onIntroDone),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.completedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Start.'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
