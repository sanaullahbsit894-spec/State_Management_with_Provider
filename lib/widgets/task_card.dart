// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AnimatedTaskCard extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onTap;

  const AnimatedTaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onTap,
  });

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 50).clamp(0, 400)),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Slidable(
            key: ValueKey(widget.task.id),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => context
                      .read<TaskProvider>()
                      .toggleTaskCompletion(widget.task.id),
                  backgroundColor: AppTheme.forest,
                  foregroundColor: Colors.white,
                  icon: widget.task.isCompleted
                      ? Icons.refresh_rounded
                      : Icons.check_rounded,
                  label: widget.task.isCompleted ? 'Undo' : 'Done',
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) =>
                      context.read<TaskProvider>().deleteTask(widget.task.id),
                  backgroundColor: Colors.redAccent.shade700,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(16),
                  ),
                ),
              ],
            ),
            child: _TaskCardBody(task: widget.task, onTap: widget.onTap),
          ),
        ),
      ),
    );
  }
}

class _TaskCardBody extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _TaskCardBody({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priorityColors = {
      Priority.low: Colors.greenAccent.shade400,
      Priority.medium: Colors.amberAccent.shade400,
      Priority.high: Colors.redAccent.shade400,
    };
    final categoryIcons = {
      TaskCategory.personal: Icons.person_rounded,
      TaskCategory.work: Icons.work_rounded,
      TaskCategory.shopping: Icons.shopping_bag_rounded,
      TaskCategory.health: Icons.favorite_rounded,
      TaskCategory.other: Icons.label_rounded,
    };

    final priorityColor = priorityColors[task.priority]!;
    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? AppTheme.surface.withOpacity(0.5)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? AppTheme.deep.withOpacity(0.3)
                : isOverdue
                ? Colors.redAccent.withOpacity(0.5)
                : AppTheme.deep.withOpacity(0.5),
          ),
          boxShadow: task.isCompleted
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.dark.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority bar
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: task.isCompleted ? AppTheme.deep : priorityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              // Checkbox
              GestureDetector(
                onTap: () =>
                    context.read<TaskProvider>().toggleTaskCompletion(task.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppTheme.forest
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? AppTheme.forest
                          : AppTheme.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: task.isCompleted
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppTheme.textSecondary,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          categoryIcons[task.category],
                          size: 12,
                          color: AppTheme.sage,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.category.name.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.sage,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (task.dueDate != null) ...[
                          const SizedBox(width: 10),
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: isOverdue
                                ? Colors.redAccent
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            DateFormat('MMM d').format(task.dueDate!),
                            style: TextStyle(
                              color: isOverdue
                                  ? Colors.redAccent
                                  : AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
