// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late Priority _priority;
  late TaskCategory _category;
  DateTime? _dueDate;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _priority = widget.task?.priority ?? Priority.medium;
    _category = widget.task?.category ?? TaskCategory.personal;
    _dueDate = widget.task?.dueDate;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TaskProvider>();

    if (_isEditing) {
      provider.updateTask(
        widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          priority: _priority,
          category: _category,
          dueDate: _dueDate,
        ),
      );
    } else {
      provider.addTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        category: _category,
        dueDate: _dueDate,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(
        backgroundColor: AppTheme.dark,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.sage),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _save,
              child: Text(
                _isEditing ? 'Update' : 'Save',
                style: const TextStyle(
                  color: AppTheme.sage,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Task Title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'What needs to be done?',
                    prefixIcon: Icon(
                      Icons.title_rounded,
                      color: AppTheme.sage,
                      size: 20,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildLabel('Description (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add some details...',
                    prefixIcon: Icon(
                      Icons.notes_rounded,
                      color: AppTheme.sage,
                      size: 20,
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Priority'),
                const SizedBox(height: 10),
                _buildPrioritySelector(),
                const SizedBox(height: 24),
                _buildLabel('Category'),
                const SizedBox(height: 10),
                _buildCategorySelector(),
                const SizedBox(height: 24),
                _buildLabel('Due Date'),
                const SizedBox(height: 10),
                _buildDatePicker(),
                const SizedBox(height: 40),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    ),
  );

  Widget _buildPrioritySelector() {
    final data = {
      Priority.low: ('Low', Colors.greenAccent.shade400),
      Priority.medium: ('Medium', Colors.amberAccent.shade400),
      Priority.high: ('High', Colors.redAccent.shade400),
    };
    return Row(
      children: data.entries.map((e) {
        final selected = _priority == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? e.value.$2.withOpacity(0.15)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? e.value.$2 : AppTheme.deep,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.flag_rounded,
                    color: selected ? e.value.$2 : AppTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.value.$1,
                    style: TextStyle(
                      color: selected ? e.value.$2 : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    final cats = {
      TaskCategory.personal: (Icons.person_rounded, 'Personal'),
      TaskCategory.work: (Icons.work_rounded, 'Work'),
      TaskCategory.shopping: (Icons.shopping_bag_rounded, 'Shopping'),
      TaskCategory.health: (Icons.favorite_rounded, 'Health'),
      TaskCategory.other: (Icons.label_rounded, 'Other'),
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cats.entries.map((e) {
        final selected = _category == e.key;
        return GestureDetector(
          onTap: () => setState(() => _category = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppTheme.forest : AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppTheme.forest : AppTheme.deep,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  e.value.$1,
                  size: 14,
                  color: selected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  e.value.$2,
                  style: TextStyle(
                    color: selected
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _dueDate != null ? AppTheme.sage : AppTheme.deep,
            width: _dueDate != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: _dueDate != null ? AppTheme.sage : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              _dueDate != null
                  ? DateFormat('EEEE, MMMM d, y').format(_dueDate!)
                  : 'No due date set',
              style: TextStyle(
                color: _dueDate != null
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (_dueDate != null)
              GestureDetector(
                onTap: () => setState(() => _dueDate = null),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.sage,
            onPrimary: AppTheme.dark,
            surface: AppTheme.surface,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.forest,
          foregroundColor: AppTheme.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          _isEditing ? 'Update Task' : 'Create Task',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
