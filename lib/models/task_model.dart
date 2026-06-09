import 'dart:convert';

enum Priority { low, medium, high }

enum TaskCategory { personal, work, shopping, health, other }

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  Priority priority;
  TaskCategory category;
  DateTime createdAt;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category = TaskCategory.personal,
    required this.createdAt,
    this.dueDate,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    TaskCategory? category,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'priority': priority.index,
    'category': category.index,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    isCompleted: json['isCompleted'] ?? false,
    priority: Priority.values[json['priority'] ?? 1],
    category: TaskCategory.values[json['category'] ?? 0],
    createdAt: DateTime.parse(json['createdAt']),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
  );

  String toJsonString() => jsonEncode(toJson());
  factory Task.fromJsonString(String source) =>
      Task.fromJson(jsonDecode(source));
}
