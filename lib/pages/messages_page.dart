import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final user = FirebaseAuth.instance.currentUser!;
  final messages = [
    {"username": "Usuario 1", "message": "Hola, ¿cómo estás?"},
  ];

  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
      backgroundColor: Color.fromARGB(236, 236, 236, 236),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index]["username"] ?? "Sin nombre"),
            subtitle: Text(messages[index]["message"] ?? "Sin nombre"),
          );
        },
      ),
    ));
  }
}
