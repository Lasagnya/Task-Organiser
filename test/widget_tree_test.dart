import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_organiser/firebase/auth.dart';
import 'package:task_organiser/firebase/firestore.dart';
import 'package:task_organiser/main.dart';
import 'package:task_organiser/model/task.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_organiser/widget_tree.dart';

Widget createWidgetTree() {
  return ChangeNotifierProvider<AuthenticationService>(create: (context) {

  })
  );
}

class MockAuth extends Mock implements FirebaseAuth {}

void main() {
  testWidgets("test", (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetTree());
  });
}