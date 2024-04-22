import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:task_organiser/firebase/firebase_options.dart';
import 'package:task_organiser/pages/profile_page.dart';
import 'package:task_organiser/pages/task_page.dart';
import 'package:task_organiser/theme/dark_mode.dart';
import 'package:task_organiser/theme/light_mode.dart';
import 'package:task_organiser/theme/theme_state.dart';
import 'package:task_organiser/util/notification_controller.dart';
import 'package:task_organiser/util/workmanager_controller.dart';
import 'package:task_organiser/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'model/task.dart';

/// Точка входа в программу.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: "remind_channel_group",
        channelKey: "remind_channel",
        channelName: "Remind",
        channelDescription: "Remind about soon tasks",
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(channelGroupKey: "remind_channel_group", channelGroupName: "Remind group"),
    ]
  );
  bool isAllowedToSendNotification = await AwesomeNotifications().isNotificationAllowed();  // проверка разрешения на уведомления
  if (!isAllowedToSendNotification)
    AwesomeNotifications().requestPermissionToSendNotifications();                          // запрос разрешения
  Workmanager().initialize(callbackDispatcher);
  runApp(ChangeNotifierProvider(
    create: (BuildContext context) => ThemeState(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );
    if (!kIsWeb && Platform.isAndroid) {
      Workmanager().registerPeriodicTask(                                             // установка фоновой задачи для присылания уведомления о приближающихся сроках
        "checkDue",
        "Check due",
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => SortFilterState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: context.watch<ThemeState>().themeMode,
        theme: lightMode,
        darkTheme: darkMode,
        home: const WidgetTree(),
        routes: {
          "/profile_page" : (context) => const ProfilePage(),
        },
      ),
    );
  }
}

/// Клас, реализующий функционал сортировки и фильтрации задач по заданным параметрам.
class SortFilterState extends ChangeNotifier {
  /// Сортировать по.
  Order orderBy = Order.dueDate;
  /// В обратном ли порядке.
  bool descending = false;
  /// Фильтровать с даты.
  DateTime filterFrom = DateTime.fromMicrosecondsSinceEpoch(0);
  /// Фильтровать по дату.
  DateTime filterTo = DateTime.now().add(const Duration(days: 36500));

  /// Отфильтрованные задачи.
  List<Task> filteredTasks = List.empty(growable: true);

  /// Изменить сортировку.
  void changeOrder(Order newOrder) {
    orderBy = newOrder;
    notifyListeners();
  }

  /// Задать условия фильтрации.
  void setFilter(DateTime from, DateTime to) {
    filterFrom = from;
    filterTo = to;
    notifyListeners();
  }

  /// Сбросить фильтры.
  void resetFilter() {
    filterFrom = DateTime.fromMicrosecondsSinceEpoch(0);
    filterTo = DateTime.now().add(const Duration(days: 36500));
    notifyListeners();
  }

  /// Отфильтровать задачи, поступившие в [allTasks].
  List<Task> filterTasks(List<Task> allTasks) {
    if (filteredTasks.isNotEmpty)
      filteredTasks.clear();
    for (int i = 0; i < allTasks.length; i++) {
      Task task = allTasks[i];
      if (task.dueDate.isAfter(filterFrom) && task.dueDate.isBefore(filterTo)) {
        filteredTasks.add(task);
      }
    }
    return filteredTasks;
  }
}
