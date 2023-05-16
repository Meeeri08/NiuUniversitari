import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jobapp/pages/chat_page.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late User? _user;

  late Stream<QuerySnapshot> _chats;

  @override
  void initState() {
    super.initState();
    _getUser();
    _getChats();
  }

  void _getUser() {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  void _getChats() {
    _chats = _firestore
        .collection('chats')
        .where('participants', arrayContains: _user!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _messageController.clear();
      Map<String, dynamic> messageData = {
        'text': message,
        'sender': _user!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'participants': [_user!.uid],
      };
      String messageId = '${_user!.uid}_${messageData['timestamp']}';
      await _firestore.collection('chats').doc(messageId).set(messageData);

      // Update the list of messages
      setState(() {
        _chats = _firestore
            .collection('chats')
            .where('participants', arrayContains: _user!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xffffffff),
            Color(0xfff9f9fa),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 60),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Missatges',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff25262b),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {});

                            // Handle favorite button press
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 120,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('recent_users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final recentUsers = snapshot.data!.docs;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentUsers.length,
                        itemBuilder: (context, index) {
                          final user =
                              recentUsers[index].data() as Map<String, dynamic>;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CircleAvatar(
// Replace with the user's profile picture
                              backgroundImage:
                                  NetworkImage(user['profile_picture']),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _chats,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final chats = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat =
                              chats[index].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(chat['sender_profile_picture']),
                            ),
                            title: Text(chat['sender_name']),
                            subtitle: Text(chat['text']),
                            trailing: Text(
                              DateFormat.Hm().format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      chat['timestamp'])),
                            ),
                            onTap: () {
                              // Navigator.of(context).push(
                              //  MaterialPageRoute(
                              // builder: (context) {
                              //return const ChatPage(
                              //id: '',
                              //  );
                              // },
                              //),
                              //  );
                            },
                          );
                        },
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
