import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskItem {
  final String id;
  final String title;
  final String priority;
  final String category;
  final DateTime date;
  final bool isCompleted;
  final bool isAiPick;

  TaskItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.category,
    required this.date,
    this.isCompleted = false,
    this.isAiPick = false,
  });

  factory TaskItem.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return TaskItem(
      id: doc.id,
      title: data['title'] ?? '',
      priority: data['priority'] ?? 'Medium',
      category: data['category'] ?? 'Work',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
      isAiPick: data['isAiPick'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'priority': priority,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isCompleted': isCompleted,
      'isAiPick': isAiPick,
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };
  }
}

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference get tasksCollection => _firestore.collection('tasks');

  // Add a task
  Future<void> addTask({
    required String title,
    required String priority,
    required String category,
    required DateTime date,
    bool isAiPick = false,
  }) async {
    if (currentUserId == null) return;

    await tasksCollection.add({
      'title': title,
      'priority': priority,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isCompleted': false,
      'isAiPick': isAiPick,
      'userId': currentUserId,
    });
  }

  // Toggle completion
  Future<void> toggleTask(String taskId, bool currentStatus) async {
    await tasksCollection.doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }

  // Get stream of all tasks for current user
  Stream<List<TaskItem>> getTasksStream() {
    if (currentUserId == null) return const Stream.empty();

    return tasksCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskItem.fromFirestore(doc)).toList());
  }
}
