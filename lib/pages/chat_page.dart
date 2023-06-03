import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatScreen extends StatefulWidget {
  final String propietariId;

  ChatScreen({required this.propietariId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? propietariName;

  @override
  void initState() {
    super.initState();
    fetchPropietariName();
  }

  void fetchPropietariName() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.propietariId)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data();
      setState(() {
        propietariName = data?['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(propietariName ?? 'Chat'),
      ),
      body: Center(
        child: Text('Chat with ${propietariName ?? 'Unknown User'}'),
      ),
    );
  }
}
