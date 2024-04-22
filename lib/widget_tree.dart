import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:task_organiser/firebase/auth.dart';
import 'package:task_organiser/pages/home_page.dart';
import 'package:task_organiser/pages/login_register_page.dart';

/// Возвращает страницу аутентификации, если вход не выполнен или домашнюю страницу в обратном случае.
class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AuthenticationService(FirebaseAuth.instance).authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        }
    );
  }
}