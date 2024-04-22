import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_organiser/firebase/auth.dart';

import '../model/task.dart';

/// Сервис, через который осуществляется взаимодействие с базой данных (Firestore).
class TaskService {
  /// Ссылка на коллекцию задач текущего пользователя
  final CollectionReference tasks = FirebaseFirestore.instance.collection(AuthenticationService(FirebaseAuth.instance).currentUser!.uid);

  /// Добавить [newTask] в коллекцию.
  Future<String> addTask(Task newTask) async {
    var document = await tasks.add({
      "task": newTask.title,
      "dueDate": newTask.dueDate,
      "description": newTask.description,
      "isCompleted": newTask.isCompleted,
      "timestamp": Timestamp.now(),
    });
    return document.id;
  }

  /// Уведомляет о изменениях в коллекции.
  Stream<QuerySnapshot> getTasksStream(String orderBy, bool descending) {
    final tasksStream = tasks.orderBy(orderBy, descending: descending).snapshots();
    return tasksStream;
  }

  /// Взять список документов коллекции.
  Future<List<QueryDocumentSnapshot<Object?>>> getTasks(String orderBy, bool descending) async {
    final snapshot = await tasks.orderBy(orderBy, descending: descending).get();
    return snapshot.docs;
  }

  /// Обновить задачу с id [docID] данными из [updatedTask].
  Future<void> updateTask(String docID, Task updatedTask) {
    return tasks.doc(docID).update({
      "task": updatedTask.title,
      "dueDate": updatedTask.dueDate,
      "description": updatedTask.description,
      "isCompleted": updatedTask.isCompleted,
      "timestamp": Timestamp.now(),
    });
  }

  /// Удалить задачу с id [docID].
  Future<void> deleteTask(String docID) {
    return tasks.doc(docID).delete();
  }
}