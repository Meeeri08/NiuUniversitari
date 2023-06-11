import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String propietariId;
  final String chatId;

  ChatScreen({required this.propietariId, required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String currentUserId;
  String? receiverName;
  String? receiverImageUrl;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    }

    _fetchReceiverData();
  }

  Future<void> _fetchReceiverData() async {
    final receiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.propietariId)
        .get();

    if (receiverDoc.exists) {
      setState(() {
        receiverName = receiverDoc.get('name');
        receiverImageUrl = receiverDoc.get('imageUrl');
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isNotEmpty) {
      final timestamp = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'receiverId': widget.propietariId,
        'message': message,
        'timestamp': timestamp,
      });

      _messageController.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (receiverImageUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(receiverImageUrl!),
              ),
            const SizedBox(width: 15),
            Text('$receiverName'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
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

                final messageDocs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: messageDocs.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messageDocs[index].data() as Map<String, dynamic>;
                    final senderId = messageData['senderId'] as String;
                    final message = messageData['message'] as String;

                    final isMe = senderId == currentUserId;

                    return Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Card(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        color: isMe ? Colors.teal : Colors.grey.shade200,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Escriu un missatge...',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                  color: Colors.teal,
                ),
                SizedBox(width: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
