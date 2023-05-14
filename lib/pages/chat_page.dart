import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late User _user;

  late Stream<QuerySnapshot> _chats;
  @override
  void initState() {
    super.initState();
    _getUser();
    _getChats();
  }

  void _getUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  void _getChats() async {
    _chats = _firestore
        .collectionGroup('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageController.clear();
      await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('chats')
          .add({
        'text': message,
        'sender': _user.displayName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(236, 236, 236, 236),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chats,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> data =
                        docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['text']),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                data['timestamp'])),
                      ),
                      trailing: Text(data['sender']),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escriu un missatge...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
