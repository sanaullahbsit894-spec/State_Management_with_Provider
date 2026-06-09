import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.deep, width: 2),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              size: 48,
              color: AppTheme.sage,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'All clear!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first task',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
