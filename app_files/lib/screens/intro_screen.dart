import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/neo_brutalist_theme.dart';

class IntroScreen extends StatelessWidget {
  final VoidCallback onDone;

  const IntroScreen({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        // Page 1: Welcome
        PageViewModel(
          title: "Welcome to Daily Tracker",
          body: "Build better habits by tracking your daily goals. Stay consistent and watch your progress grow over time.",
          image: _buildImage(
            Icons.task_alt,
            AppTheme.completedColor,
          ),
          decoration: _getPageDecoration(),
        ),
        // Page 2: How it works
        PageViewModel(
          title: "Track Your Progress",
          body: "Add your daily goals, mark them complete, and see your completion rate improve. The progress bar changes color based on how well you're doing!",
          image: _buildImage(
            Icons.trending_up,
            const Color(0xFF007AFF),
          ),
          decoration: _getPageDecoration(),
        ),
      ],
      onDone: () async {
        // Save that user has seen intro
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenIntro', true);
        onDone();
      },
      onSkip: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenIntro', true);
        onDone();
      },
      showSkipButton: true,
      skip: Text(
        "Skip",
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      next: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.completedColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Text(
          "Next",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      done: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.completedColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Text(
          "Get Started",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size(10, 10),
        color: Colors.grey.shade300,
        activeSize: const Size(22, 10),
        activeColor: AppTheme.completedColor,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      globalBackgroundColor: Colors.white,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildImage(IconData icon, Color color) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 100,
          color: color,
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
        height: 1.5,
      ),
      imagePadding: const EdgeInsets.only(top: 80, bottom: 24),
      contentMargin: const EdgeInsets.symmetric(horizontal: 24),
      pageColor: Colors.white,
    );
  }
}
