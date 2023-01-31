import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final user = FirebaseAuth.instance.currentUser!;

  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
      backgroundColor: Color.fromARGB(236, 236, 236, 236),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
    ));
  }
}
