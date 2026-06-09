// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildStatsBar(),
          _buildFilterChips(),
          _buildTaskList(),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _openAddTask(context),
          backgroundColor: AppTheme.forest,
          icon: const Icon(Icons.add_rounded, color: AppTheme.textPrimary),
          label: const Text(
            'New Task',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.dark,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TaskFlow',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Consumer<TaskProvider>(
              builder: (_, p, _) => Text(
                '${p.pendingTasks} tasks remaining',
                style: const TextStyle(
                  color: AppTheme.sage,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.dark, AppTheme.surface],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.sage),
          onPressed: () => _confirmDeleteCompleted(context),
          tooltip: 'Clear completed',
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return SliverToBoxAdapter(
      child: Consumer<TaskProvider>(
        builder: (_, provider, _) {
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.deep.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatChip(
                      label: 'Total',
                      value: '${provider.totalTasks}',
                      color: AppTheme.sage,
                    ),
                    _StatChip(
                      label: 'Done',
                      value: '${provider.completedTasks}',
                      color: AppTheme.forest,
                    ),
                    _StatChip(
                      label: 'Pending',
                      value: '${provider.pendingTasks}',
                      color: AppTheme.deep,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: provider.completionRate),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    builder: (_, val, _) => LinearProgressIndicator(
                      value: val,
                      backgroundColor: AppTheme.dark,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.sage),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(provider.completionRate * 100).toStringAsFixed(0)}% completed',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Consumer<TaskProvider>(
        builder: (_, provider, _) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                for (final f in ['All', 'Active', 'Completed'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: f,
                      selected: provider.filter == f,
                      onTap: () => provider.setFilter(f),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: AppTheme.deep),
                const SizedBox(width: 8),
                for (final p in Priority.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _PriorityChip(
                      priority: p,
                      selected: provider.priorityFilter == p,
                      onTap: () => provider.setPriorityFilter(
                        provider.priorityFilter == p ? null : p,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (_, provider, _) {
        if (provider.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.sage),
            ),
          );
        }

        final tasks = provider.tasks;

        if (tasks.isEmpty) {
          return const SliverFillRemaining(child: EmptyState());
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return AnimatedTaskCard(
                key: ValueKey(tasks[index].id),
                task: tasks[index],
                index: index,
                onTap: () => _openEditTask(context, tasks[index]),
              );
            }, childCount: tasks.length),
          ),
        );
      },
    );
  }

  void _openAddTask(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, _) => const AddEditTaskScreen(),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  void _openEditTask(BuildContext context, task) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, _) => AddEditTaskScreen(task: task),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  void _confirmDeleteCompleted(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Clear Completed',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Remove all completed tasks?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.sage)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              context.read<TaskProvider>().deleteCompleted();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.sage : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.sage : AppTheme.deep),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.dark : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final Priority priority;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = {
      Priority.low: Colors.greenAccent.shade400,
      Priority.medium: Colors.amberAccent.shade400,
      Priority.high: Colors.redAccent.shade400,
    };
    final labels = {
      Priority.low: '↓ Low',
      Priority.medium: '→ Med',
      Priority.high: '↑ High',
    };
    final color = colors[priority]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppTheme.deep),
        ),
        child: Text(
          labels[priority]!,
          style: TextStyle(
            color: selected ? color : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
