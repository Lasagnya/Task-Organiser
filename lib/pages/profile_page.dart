import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:task_organiser/firebase/auth.dart';

import '../theme/theme_state.dart';

/// Страница настроек и информации о пользователе.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("User details:"),
            Text(AuthenticationService(FirebaseAuth.instance).currentUser!.email!),
            ElevatedButton(
              onPressed: () {
                AuthenticationService(FirebaseAuth.instance).signOut();
                Navigator.pushNamedAndRemoveUntil(context,'/',(_) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
              child: const Text("Sign out"),
            ),
            const SizedBox(height: 100,),
            TextButton(
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    actionsPadding: const EdgeInsets.only(left: 15, top: 0, right: 0, bottom: 0),
                    title: const Text("Choose theme"),
                    actions: [
                      RadioListTile<ThemeMode>(
                        contentPadding: const EdgeInsets.all(0),
                        title: const Text("System default"),
                        value: ThemeMode.system,
                        groupValue: themeState.themeMode,
                        onChanged: (value) => themeState.changeMode(value!),
                      ),
                      RadioListTile<ThemeMode>(
                        contentPadding: const EdgeInsets.all(0),
                        title: const Text("Light"),
                        value: ThemeMode.light,
                        groupValue: themeState.themeMode,
                        onChanged: (value) => themeState.changeMode(value!),
                      ),
                      RadioListTile<ThemeMode>(
                        contentPadding: const EdgeInsets.all(0),
                        title: const Text("Dark"),
                        value: ThemeMode.dark,
                        groupValue: themeState.themeMode,
                        onChanged: (value) => themeState.changeMode(value!),
                      ),
                    ],
                  );
                });
              },
              child: const Text("Change theme"),
            ),
          ],
        ),
      ),
    );
  }
}