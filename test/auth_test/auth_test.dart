import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task_organiser/firebase/auth.dart';

class MockUser extends Mock implements User {}
final MockUser _mockUser = MockUser();

class MockUserCredentials extends Mock implements UserCredential {}
final MockUserCredentials _mockUserCredentials = MockUserCredentials();

class MockAuth extends Mock implements FirebaseAuth {
  @override
  Stream<User> authStateChanges() {
    return Stream.fromIterable([
      _mockUser,
    ]);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _mockUserCredentials;
  }
}

Future<void> main() async {
  final MockAuth mockFirebaseAuth = MockAuth();
  final AuthenticationService auth = AuthenticationService(mockFirebaseAuth);

  test("get user", () async {
    expectLater(auth.authStateChanges, emitsInOrder([_mockUser]));
  });

  test("create account", () async {
    // when(mockFirebaseAuth.createUserWithEmailAndPassword(email: "test@test.com", password: "12345678"),
    // ).thenAnswer((invocation) => Future(() => _mockUserCredentials));
    expectLater(await auth.createUserWithEmailAndPassword("test@test.com", "12345678"), _mockUserCredentials);
  });

}