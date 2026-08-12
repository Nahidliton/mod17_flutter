import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_task_manager/models/task.dart';
import 'package:student_task_manager/models/user_profile.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  static CollectionReference get _usersCollection => _firestore.collection('users');
  static CollectionReference get _tasksCollection => _firestore.collection('tasks');

  // ============================================================
  // USER METHODS
  // ============================================================

  static Future<void> saveUser(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.email).set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  static Future<UserProfile?> loadUser(String email) async {
    try {
      final doc = await _usersCollection.doc(email).get();
      if (!doc.exists) {
        return null;
      }
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  static Future<void> updateUser(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.email).update(profile.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  static Future<bool> userExists(String email) async {
    try {
      final doc = await _usersCollection.doc(email).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // TASK METHODS
  // ============================================================

  static Future<List<Task>> loadTasksForUser(String email) async {
    try {
      final querySnapshot = await _tasksCollection
          .where('userEmail', isEqualTo: email)
          .orderBy('dueDate', descending: false)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If no tasks exist, return empty list
      return [];
    }
  }

  static Future<void> saveTasksForUser(String email, List<Task> tasks) async {
    try {
      // Get existing task IDs
      final existingSnapshot = await _tasksCollection
          .where('userEmail', isEqualTo: email)
          .get();
      
      final existingIds = existingSnapshot.docs.map((doc) => doc.id).toList();
      
      // Delete tasks that are no longer in the list
      final currentIds = tasks.map((task) => task.id).toList();
      final idsToDelete = existingIds.where((id) => !currentIds.contains(id)).toList();
      
      for (String id in idsToDelete) {
        await _tasksCollection.doc(id).delete();
      }
      
      // Save or update tasks
      for (Task task in tasks) {
        final taskMap = task.toMap();
        taskMap['userEmail'] = email; // Add user email for querying
        
        await _tasksCollection.doc(task.id).set(taskMap, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to save tasks: $e');
    }
  }

  static Future<void> saveTask(String email, Task task) async {
    try {
      final taskMap = task.toMap();
      taskMap['userEmail'] = email;
      await _tasksCollection.doc(task.id).set(taskMap, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save task: $e');
    }
  }

  static Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  static Future<void> deleteAllTasksForUser(String email) async {
    try {
      final querySnapshot = await _tasksCollection
          .where('userEmail', isEqualTo: email)
          .get();
      
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete tasks: $e');
    }
  }

  // ============================================================
  // REAL-TIME LISTENERS
  // ============================================================

  static Stream<List<Task>> streamTasksForUser(String email) {
    return _tasksCollection
        .where('userEmail', isEqualTo: email)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  static Stream<UserProfile?> streamUser(String email) {
    return _usersCollection
        .doc(email)
        .snapshots()
        .map((doc) => doc.exists 
            ? UserProfile.fromMap(doc.data() as Map<String, dynamic>)
            : null);
  }
}