import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ObjectScreen extends StatefulWidget {
  const ObjectScreen({Key? key}) : super(key: key);

  @override
  State<ObjectScreen> createState() => _ObjectScreenState();
}

class _ObjectScreenState extends State<ObjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          color: Color.fromARGB(236, 236, 236, 236),
        ),
      ),
    );
  }
}
