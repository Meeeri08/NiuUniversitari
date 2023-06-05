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
  void saveChatMessage(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    final chatRef = FirebaseFirestore.instance.collection('chats');

    if (user != null) {
      await chatRef.add({
        'senderId': user.uid,
        'receiverId': widget.propietariId,
        'message': message,
        'timestamp': Timestamp.now(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Center(
        child: Text('Chat with ${widget.propietariId}'),
      ),
    );
  }
}
