import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:task_organiser/firebase/firestore.dart';
import 'package:task_organiser/main.dart';

import '../model/task.dart';

/// Страница с задачами.
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  /// Сервис задач для взаимодействия с базой данных.
  final TaskService taskService = TaskService();

  /// Открыть диалог с созданием или редактированием задачи.
  void openTaskBox(Task? task) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        if (task == null) {
          return TaskDialog(onPressed: (String? docID, String title, String description, DateTime selectedDateTime, bool isCompleted) {
            Task newTask = Task(title, selectedDateTime, description, isCompleted);
            taskService.addTask(newTask);
          });
        } else {
          return TaskDialog(currentTask: task, onPressed: (String? docID, String title, String description, DateTime selectedDateTime, bool isCompleted) {
            Task updatedTask = Task(title, selectedDateTime, description, isCompleted);
            taskService.updateTask(docID!, updatedTask);
          });
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<SortFilterState>();

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(                                                       // кнопка сортировки
              onPressed: () {
                showModalBottomSheet(context: context, builder: (context) {
                  return const SortRadiaDialog();
                });
              },
              icon: const Icon(Icons.sort),
            ),
            IconButton(                                                           // кнопка фильтрации
              onPressed: () {
                showModalBottomSheet(context: context, builder: (context) {
                  return const FilterDialog();
                });
              },
              icon: const Icon(Icons.filter_alt),),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () async {
          openTaskBox(null);
          },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(                                                                     // по уведомлениям от базы данных об изменении в ней строит список задач
        stream: taskService.getTasksStream(appState.orderBy.name, appState.descending),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Task> allTask = snapshot.data!.docs.map((document) {
              return Task.fromDocument(document);
            }).toList();
            List<Task> filteredList = appState.filterTasks(allTask);              // фильтрует задачи
            if (filteredList.isEmpty) {
              return Center(child: Text("No tasks", style: Theme.of(context).textTheme.titleMedium,));        // если задач нет, то текст
            } else {
              return ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  Task task = filteredList[index];
                  final dateFormat = task.dueDate.year == DateTime.now().year ? DateFormat("E, d MMM, H:mm") : DateFormat("E, d MMM y, H:mm");

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                    leading: IconButton(
                      onPressed: () {
                        task.isCompleted = !task.isCompleted;
                        taskService.updateTask(task.docID, task);
                      },
                      icon: task.isCompleted ? const Icon(Icons.check_circle) : const Icon(Icons.check_circle_outline),         // кнопка отметки задачи выполненной
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          padding: const EdgeInsets.only(top: 3.0, bottom: 3.0, left: 15.0, right: 15.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          child: Text(dateFormat.format(task.dueDate)),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(                                                 // кнопка удаления задачи
                          onPressed: () => taskService.deleteTask(task.docID),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),

                    onTap: () => openTaskBox(task),
                  );
                }
            );
            }
          } else {
            return Center(child: Text("No tasks", style: Theme.of(context).textTheme.titleMedium,));
          }
        },
      ),
    );
  }
}

/// Перечисление вариантов сортировки.
enum Order {dueDate, timestamp}

/// Диалог фильтрации.
class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late DateTime fromPicked;
  late DateTime toPicked;

  /// Обновляет диалог каждый раз при изменении значений фильтрации.
  @override
  void didChangeDependencies() {
    final appState = context.watch<SortFilterState>();
    fromPicked = appState.filterFrom;
    toPicked = appState.filterTo;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<SortFilterState>();
    final dateFormat = DateFormat("d MMM y");

    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filter"),
          Row(
            children: [
              const Text("from"),
              TextButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                    lastDate: toPicked,
                  );
                  if (picked != null && picked != fromPicked) {
                    setState(() {
                      fromPicked = picked;
                    });
                  }
                },
                child: Text(dateFormat.format(fromPicked)),
              ),

              const Text("to"),
              TextButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    firstDate: fromPicked,
                    lastDate: DateTime.now().add(const Duration(days: 36500)),
                  );
                  if (picked != null && picked != toPicked) {
                    setState(() {
                      toPicked = picked;
                    });
                  }
                },
                child: Text(dateFormat.format(toPicked)),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(child: SizedBox(),),
              TextButton(
                onPressed: () {
                  appState.resetFilter();
                },
                child: const Text("Reset filters"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  appState.setFilter(fromPicked, toPicked);
                },
                child: const Text("Apply"),
              ),
            ]
          )
        ],
      ),
    );
  }
}

/// Диалог выбора сортировки.
class SortRadiaDialog extends StatelessWidget {

  const SortRadiaDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<SortFilterState>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24.0, bottom: 10.0),
              child: Text("Sort by"),
            ),
            RadioListTile<Order>(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                title: const Text("Addition time"),
                value: Order.timestamp,
                groupValue: appState.orderBy,
                onChanged: (value) => appState.changeOrder(value!),
            ),
            RadioListTile<Order>(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                title: const Text("Due date"),
                value: Order.dueDate,
                groupValue: appState.orderBy,
                onChanged: (value) => appState.changeOrder(value!),
            ),
          ]
      ),
    );
  }
}

/// Диалог создания и изменения задачи.
class TaskDialog extends StatefulWidget {
  /// Текущая задача (если есть, для редактирования).
  final Task? currentTask;
  final Function(String? docID, String title, String description, DateTime selectedDateTime, bool isCompleted) onPressed;

  const TaskDialog({super.key, this.currentTask, required this.onPressed});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final TextEditingController titleController = TextEditingController();
  late final DateTime currentDateTime;
  final TextEditingController descriptionController = TextEditingController();
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentTask != null) {
      titleController.text = widget.currentTask!.title;
      currentDateTime = widget.currentTask!.dueDate;
      descriptionController.text = widget.currentTask!.description;
      isCompleted = widget.currentTask!.isCompleted;
    }
    else {
      currentDateTime = DateTime.now();
    }
    selectedDate = currentDateTime;
    selectedTime = TimeOfDay.fromDateTime(currentDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("E, d MMM y");
    final timeFormat = DateFormat("Hm");
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            controller: titleController,
            decoration: const InputDecoration(
              hintText: "New task"
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft
                  ),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                      lastDate: currentDateTime.add(const Duration(days: 36500)),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(dateFormat.format(selectedDate)),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    alignment: Alignment.centerRight
                ),
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null && picked != selectedTime) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
                child: Text(timeFormat.format(DateTime(selectedDate.year, 1, 1, selectedTime.hour, selectedTime.minute))),
              )
            ],
          ),

          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            autofocus: true,
            controller: descriptionController,
            decoration: const InputDecoration(
                hintText: "Details"
            ),
          ),

          const SizedBox(
            height: 15.0,
          ),

          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isCompleted = !isCompleted;
                      });
                    },
                    icon: isCompleted ? const Icon(Icons.check_circle) : const Icon(Icons.check_circle_outline),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onPressed(
                    widget.currentTask?.docID,
                    titleController.text,
                    descriptionController.text,
                    DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
                    isCompleted,
                  );

                  titleController.clear();
                  descriptionController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          )
        ],
      ),
    );
  }
}