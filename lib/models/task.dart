import 'package:intl/intl.dart';

class Task {
  final String id;
  String title;
  String description;
  String subject;
  DateTime dueDate;
  String priority;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      subject: map['subject'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: map['priority'] as String,
      isCompleted: map['isCompleted'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  String get dueDateFormatted {
    return DateFormat('MMM d, y').format(dueDate);
  }
}
