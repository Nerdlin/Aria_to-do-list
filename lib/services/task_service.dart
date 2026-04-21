import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.category,
    required this.date,
    required this.durationMinutes,
    required this.isCompleted,
    required this.isAiPick,
    required this.createdAt,
    this.completedAt,
    this.note = '',
  });

  final String id;
  final String title;
  final String priority;
  final String category;
  final DateTime date;
  final int durationMinutes;
  final bool isCompleted;
  final bool isAiPick;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String note;

  factory TaskItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TaskItem(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      priority: (data['priority'] as String?) ?? 'Medium',
      category: (data['category'] as String?) ?? 'Work',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: data['durationMinutes'] as int? ?? 60,
      isCompleted: data['isCompleted'] as bool? ?? false,
      isAiPick: data['isAiPick'] as bool? ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['date'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      note: (data['note'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'priority': priority,
      'category': category,
      'date': Timestamp.fromDate(date),
      'durationMinutes': durationMinutes,
      'isCompleted': isCompleted,
      'isAiPick': isAiPick,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'note': note,
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };
  }
}

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get tasksCollection =>
      _firestore.collection('tasks');

  Future<void> addTask({
    required String title,
    required String priority,
    required String category,
    required DateTime date,
    required int durationMinutes,
    String note = '',
    bool isAiPick = false,
  }) async {
    if (currentUserId == null) {
      return;
    }

    await tasksCollection.add({
      'title': title,
      'priority': priority,
      'category': category,
      'date': Timestamp.fromDate(date),
      'durationMinutes': durationMinutes,
      'isCompleted': false,
      'isAiPick': isAiPick,
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
      'note': note,
      'userId': currentUserId,
    });
  }

  Future<void> toggleTask(String taskId, bool currentStatus) async {
    await tasksCollection.doc(taskId).update({
      'isCompleted': !currentStatus,
      'completedAt': !currentStatus ? FieldValue.serverTimestamp() : null,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }

  Stream<List<TaskItem>> getTasksStream() {
    if (currentUserId == null) {
      return Stream.value(const <TaskItem>[]);
    }

    return tasksCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskItem.fromFirestore(doc)).toList(),
        );
  }
}
