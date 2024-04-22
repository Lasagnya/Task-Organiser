import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_organiser/pages/task_page.dart';

/// Домашняя страница приложения с AppBar и телом из [TaskPage].
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/profile_page");
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: const TaskPage(),
    );
  }
}