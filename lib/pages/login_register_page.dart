import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_organiser/firebase/auth.dart';

/// Страница аутентификации.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Ошибки, полученные при валидации данных провайдером аутентификации.
  String? errorMessage = "";
  var isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await AuthenticationService(FirebaseAuth.instance).signInWithEmailAndPassword(_controllerEmail.text, _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createInWithEmailAndPassword() async {
    try {
      await AuthenticationService(FirebaseAuth.instance).createUserWithEmailAndPassword(_controllerEmail.text, _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task,
                size: 75,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              const SizedBox(height: 40,),
              LoginTextField(
                labelText: "Email",
                controller: _controllerEmail,
              ),
              const SizedBox(height: 15,),
              LoginTextField(
                labelText: "Password",
                controller: _controllerPassword, obscureText: true,
              ),
              Text(errorMessage.toString()),
              const SizedBox(height: 20,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(150, 50),
                ),
                onPressed: isLogin ? signInWithEmailAndPassword : createInWithEmailAndPassword,
                child: Text(isLogin ? "Login" : "Register")
              ),
              const SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isLogin ? "Don't have an account?" : "Already have an account?"),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(isLogin ? "Register instead" : "Login instead")
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Поле ввода email и пароля.
class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final Icon? decorationIcon;

  const LoginTextField({super.key, required this.labelText, required this.controller, this.obscureText = false, this.decorationIcon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        icon: decorationIcon,
        border: const OutlineInputBorder(),
        labelText: labelText,
      ),
      obscureText: obscureText,
    );
  }
}