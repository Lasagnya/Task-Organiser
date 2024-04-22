import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель задачи для сохранения и получения из базы данных.
class Task {
  /// id задачи.
  String _docID = "";
  /// Заголовок задачи.
  late String _title;
  /// Назначенное время задачи.
  late DateTime _dueDate;
  /// Необязательное описание задачи.
  late String _description;
  /// Отмечена ли задача завершённой.
  late bool _isCompleted;

  /// Создаёт задачу со всеми полями, кроме id.
  Task(this._title, this._dueDate, [this._description = "", this._isCompleted = false]);

  /// Создает задачу из DocumentSnapshot [document].
  Task.fromDocument(DocumentSnapshot document) {
    _docID = document.id;
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    _title = data["task"];
    _dueDate = data["dueDate"].toDate();
    _description = data["description"];
    _isCompleted = data["isCompleted"];
  }

  bool get isCompleted => _isCompleted;

  set isCompleted(bool value) {
    _isCompleted = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  DateTime get dueDate => _dueDate;

  set dueDate(DateTime value) {
    _dueDate = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get docID => _docID;

  set docID(String value) {
    _docID = value;
  }
}