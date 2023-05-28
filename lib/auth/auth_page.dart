import 'package:flutter/material.dart';
import 'package:jobapp/pages/login_page.dart';
import 'package:jobapp/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showRegisterPage = true;
  void toggleScreens() {
    setState(() {
      showRegisterPage = !showRegisterPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showRegisterPage) {
      return RegisterPage(showLoginPage: toggleScreens);
    } else {
      return LoginPage(showRegisterPage: toggleScreens);
    }
  }
}
