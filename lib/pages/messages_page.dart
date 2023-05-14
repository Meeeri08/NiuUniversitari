import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
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
        .collection('chats')
        .where('participants', arrayContains: _user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageController.clear();
      Map<String, dynamic> messageData = {
        'text': message,
        'sender': _user.uid, // Use the UID of the user who sent the message
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'participants': [
          _user.uid
        ], // Add the user's UID to the list of participants
      };
      String messageId = '${_user.uid}_${messageData['timestamp']}';
      await _firestore.collection('chats').doc(messageId).set(messageData);

      // Update the list of messages
      setState(() {
        _chats = _firestore
            .collection('chats')
            .where('participants', arrayContains: _user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots();
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
                    String sender = data['sender'] ?? '';
                    return ListTile(
                      title: Text(data['text']),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                data['timestamp'])),
                      ),
                      trailing: Text(sender),
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
