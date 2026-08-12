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
  String _selectedView = 'All';

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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
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
      final searchMatch = task.title.toLowerCase().contains(query) ||
          task.subject.toLowerCase().contains(query);
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
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: task),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredTasks = _filteredTasks;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          const ThemeToggle(),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 22,
              ),
            ),
            onPressed: () async {
              await Navigator.pushNamed(context, ProfileScreen.routeName);
              await _loadTasks();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskEditor(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C63FF),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildQuickFilters(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredTasks.isEmpty
                          ? const EmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 20),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $_userName 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You have ${_pendingCount} pending tasks',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              label: 'Pending',
              value: _pendingCount,
              color: const Color(0xFFFF6584),
              icon: Icons.pending_actions,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              label: 'Completed',
              value: _completedCount,
              color: const Color(0xFF4CAF50),
              icon: Icons.check_circle,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              label: 'Total',
              value: _tasks.length,
              color: const Color(0xFF6C63FF),
              icon: Icons.task,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1A2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF6C63FF),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildQuickFilters() {
    final filters = ['All', 'Pending', 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedView == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedView = filter;
                  _statusFilter = filter == 'All' ? 'All' : filter;
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: const Color(0xFF6C63FF).withAlpha(30),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide.none
                    : BorderSide(
                        color: Theme.of(context).colorScheme.onSurfaceVariant
                            .withAlpha(40),
                      ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}