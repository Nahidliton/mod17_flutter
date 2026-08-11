import 'package:flutter/material.dart';
import 'package:student_task_manager/models/task.dart';
import 'package:student_task_manager/screens/add_edit_task_screen.dart';
import 'package:student_task_manager/screens/profile_screen.dart';
import 'package:student_task_manager/services/auth_service.dart';
import 'package:student_task_manager/services/storage_service.dart';
import 'package:student_task_manager/widgets/empty_state.dart';
import 'package:student_task_manager/widgets/theme_toggle.dart';
import 'package:student_task_manager/widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Task> _tasks = [];
  bool _loading = true;
  String _priorityFilter = 'All';
  String _statusFilter = 'All';
  String _userName = 'Student';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final email = AuthService.currentUserEmail;
    if (email == null) {
      return;
    }
    setState(() => _loading = true);
    _tasks = await StorageService.loadTasksForUser(email);
    final profile = await StorageService.loadUser(email);
    if (profile != null) {
      _userName = profile.name;
    }
    setState(() => _loading = false);
  }

  Future<void> _saveTasks() async {
    final email = AuthService.currentUserEmail;
    if (email == null) {
      return;
    }
    await StorageService.saveTasksForUser(email, _tasks);
  }

  void _toggleTaskCompletion(Task task) async {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    await _saveTasks();
  }

  void _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete')),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }
    setState(() {
      _tasks.removeWhere((element) => element.id == task.id);
    });
    await _saveTasks();
  }

  List<Task> get _filteredTasks {
    final query = _searchController.text.toLowerCase();
    return _tasks.where((task) {
      final searchMatch = task.title.toLowerCase().contains(query);
      final priorityMatch =
          _priorityFilter == 'All' || task.priority == _priorityFilter;
      final statusMatch = _statusFilter == 'All' ||
          (_statusFilter == 'Pending' ? !task.isCompleted : task.isCompleted);
      return searchMatch && priorityMatch && statusMatch;
    }).toList();
  }

  int get _pendingCount => _tasks.where((task) => !task.isCompleted).length;
  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  Future<void> _openTaskEditor([Task? task]) async {
    final result = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(builder: (context) => AddEditTaskScreen(task: task)),
    );
    if (result != null) {
      final existingIndex = _tasks.indexWhere((item) => item.id == result.id);
      setState(() {
        if (existingIndex >= 0) {
          _tasks[existingIndex] = result;
        } else {
          _tasks.add(result);
        }
      });
      await _saveTasks();
    }
  }

  Future<void> _refresh() async {
    await _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          const ThemeToggle(),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.pushNamed(context, ProfileScreen.routeName);
              await _loadTasks();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskEditor(),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildFilters(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: filteredTasks.isEmpty
                          ? const EmptyState(
                              title: 'No tasks found',
                              message:
                                  'Add a task or change your search and filters to see more tasks.',
                            )
                          : ListView.builder(
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return TaskCard(
                                  task: task,
                                  onToggleComplete: () =>
                                      _toggleTaskCompletion(task),
                                  onEdit: () => _openTaskEditor(task),
                                  onDelete: () => _deleteTask(task),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back,',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        Text(_userName,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: _buildStatusCard(
                    'Pending',
                    _pendingCount,
                    const Color.fromRGBO(255, 165, 0, 0.12),
                    const Color.fromRGBO(255, 165, 0, 1))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildStatusCard(
                    'Completed',
                    _completedCount,
                    const Color.fromRGBO(76, 175, 80, 0.12),
                    const Color.fromRGBO(76, 175, 80, 1))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(
      String label, int value, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text('$value',
              style: TextStyle(
                  color: textColor, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search tasks by title',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _priorityFilter,
            items: ['All', 'Low', 'Medium', 'High']
                .map((label) =>
                    DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: (value) =>
                setState(() => _priorityFilter = value ?? 'All'),
            decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _statusFilter,
            items: ['All', 'Pending', 'Completed']
                .map((label) =>
                    DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: (value) =>
                setState(() => _statusFilter = value ?? 'All'),
            decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14))),
          ),
        ),
      ],
    );
  }
}
