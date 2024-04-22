import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:task_organiser/firebase/firestore.dart';
import 'package:workmanager/workmanager.dart';

import '../model/task.dart';

/// Контроллер фоновых задач.
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "checkDue":
        List documents = await TaskService().getTasks("dueDate", false);
        for (int i = 0; i < documents.length; i++) {
          Task task = Task.fromDocument(documents[i]);
          if (task.dueDate.isBefore(DateTime.now().add(const Duration(hours: 1))) && task.isCompleted == false) {       // присылает уведомление, если до задачи меньше часа и она не выполнена
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: UniqueKey().hashCode,
                channelKey: "remind_channel",
                title: "Soon to be ${task.title}",
              ),
            );
          }
        }
    }
    return Future.value(true);
  });
}