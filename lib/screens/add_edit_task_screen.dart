import 'package:flutter/material.dart';
import 'package:student_task_manager/models/task.dart';
import 'package:student_task_manager/services/auth_service.dart';
import 'package:student_task_manager/services/storage_service.dart';
import 'package:student_task_manager/widgets/custom_text_field.dart';
import 'package:student_task_manager/widgets/theme_toggle.dart';
import 'package:uuid/uuid.dart';

class AddEditTaskScreen extends StatefulWidget {
  static const routeName = '/task-editor';
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'Low';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _subjectController.text = widget.task!.subject;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365 * 2)),
    );
    if (selected != null) {
      setState(() => _dueDate = selected);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date.')));
      return;
    }
    setState(() => _saving = true);

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subject: _subjectController.text.trim(),
      dueDate: _dueDate!,
      priority: _priority,
      isCompleted: widget.task?.isCompleted ?? false,
    );
    final email = AuthService.currentUserEmail;
    if (email == null) {
      return;
    }
    final tasks = await StorageService.loadTasksForUser(email);
    final existingIndex = tasks.indexWhere((element) => element.id == task.id);
    if (existingIndex >= 0) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }
    await StorageService.saveTasksForUser(email, tasks);
    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    return Scaffold(
          appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Add Task'), actions: [const ThemeToggle()]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                      controller: _titleController,
                      label: 'Title',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Title is required'
                          : null),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _subjectController,
                      label: 'Subject',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Subject is required'
                          : null),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hintText: 'Describe the task',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Description is required'
                          : null),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickDueDate,
                          child: Text(_dueDate == null
                              ? 'Select Due Date'
                              : 'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    items: ['Low', 'Medium', 'High']
                        .map((label) =>
                            DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _priority = value ?? 'Low'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveTask,
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3, color: Colors.white))
                          : Text(isEditing ? 'Save Changes' : 'Add Task'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
