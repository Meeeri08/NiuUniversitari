import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String propietariId;

  ChatScreen({required this.propietariId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _chatStream;
  Map<String, dynamic> _userNames = {};

  String _buildMessageSubtitle(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final formattedTime = DateFormat.Hm().format(dateTime);
    return formattedTime;
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _chatStream = _firestore
          .collection('chats')
          .orderBy('lastMessageTimestamp', descending: true)
          .where('users', arrayContains: user.uid)
          .snapshots();
    }

    fetchUserNames();
  }

  void fetchUserNames() async {
    final snapshot = await _firestore.collection('users').get();

    if (snapshot.docs.isNotEmpty) {
      final userNames = Map<String, dynamic>.fromEntries(
        snapshot.docs.map((doc) => MapEntry(doc.id, doc.data()['name'])),
      );

      setState(() {
        _userNames = userNames;
      });
    }
  }

  void saveChatMessage(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    final chatRef = FirebaseFirestore.instance.collection('chats');

    if (user != null) {
      // Get the chat document between the sender and receiver
      final querySnapshot = await chatRef
          .where('users', arrayContains: user.uid)
          .where('users', arrayContains: widget.propietariId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If the chat document already exists, update it
        final chatDoc = querySnapshot.docs.first;

        // Get the chat ID and reference the messages subcollection
        final chatId = chatDoc.id;
        final messagesRef = chatDoc.reference.collection('messages');

        // Update the document with the new message
        await messagesRef.add({
          'senderId': user.uid,
          'receiverId': widget.propietariId,
          'message': message,
          'timestamp': Timestamp.now(),
        });

        // Update the chat document with the latest message details
        await chatDoc.reference.update({
          'lastMessage': message,
          'lastMessageTimestamp': Timestamp.now(),
        });
      } else {
        // If the chat document doesn't exist, create a new one
        final docRef = await chatRef.add({
          'users': [user.uid, widget.propietariId],
          'lastMessage': message,
          'lastMessageTimestamp': Timestamp.now(),
        });

        final chatId = docRef.id;

        // Create a subcollection for messages and add the first message
        final messagesRef = docRef.collection('messages');
        await messagesRef.add({
          'senderId': user.uid,
          'receiverId': widget.propietariId,
          'message': message,
          'timestamp': Timestamp.now(),
        });
      }

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_userNames[widget.propietariId] ?? ''}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final chatDocuments = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocuments.length,
                  itemBuilder: (context, index) {
                    final chatDocument = chatDocuments[index];
                    final chatId = chatDocument.id;

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _firestore
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .orderBy('timestamp')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final messages = snapshot.data!.docs;

                        return ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                messages[index].data() as Map<String, dynamic>;
                            final senderId = message['senderId'] as String;
                            final receiverId = message['receiverId'] as String;
                            final senderName = _userNames[senderId] ?? '';
                            final timestamp = message['timestamp'] as Timestamp;

                            final isSender = senderId ==
                                FirebaseAuth.instance.currentUser?.uid;

                            return ListTile(
                              title: Align(
                                alignment: isSender
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Text(message['message'] as String),
                              ),
                              subtitle: Text(_buildMessageSubtitle(timestamp)),
                              tileColor: isSender ? Colors.blue : Colors.green,
                              trailing:
                                  isSender ? null : Icon(Icons.arrow_forward),
                              leading: isSender ? Icon(Icons.arrow_back) : null,
                              contentPadding: isSender
                                  ? EdgeInsets.only(left: 64.0)
                                  : EdgeInsets.only(right: 64.0),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      saveChatMessage(message);
                    }
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
