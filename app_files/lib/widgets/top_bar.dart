import 'package:flutter/material.dart';
import '../../theme/neo_brutalist_theme.dart';

class TopBar extends StatelessWidget {
  final int streak;

  const TopBar({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App Title
            const Text('DAILY TRACKER', style: NeoBrutalistTheme.headingStyle),
            // Streak Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: NeoBrutalistTheme.boxDecoration,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 20,
                    color: NeoBrutalistTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text('STREAK: $streak', style: NeoBrutalistTheme.buttonStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
