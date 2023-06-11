import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jobapp/pages/chat_page.dart';

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Messages',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: const Color(0xff25262b),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUser?.uid)
            .orderBy('lastMessageTimestamp', descending: true)
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

          final chatDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              final users = chatData['users'] as List<dynamic>;
              final otherUserId = users.firstWhere(
                (userId) => userId != currentUser?.uid,
              ) as String;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  final receiverName = userData?['name'] as String?;
                  final receiverImageUrl = userData?['imageUrl'] as String?;
                  final lastMessage = chatData['lastMessage'] as String;
                  final lastMessageTimestamp = chatData['lastMessageTimestamp'];

                  final lastMessageTime = lastMessageTimestamp != null
                      ? DateFormat.Hm().format(lastMessageTimestamp.toDate())
                      : '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(receiverImageUrl ?? ''),
                    ),
                    title: Text(receiverName ?? ''),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lastMessage,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(lastMessageTime),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            propietariId: otherUserId,
                            chatId: chatDocs[index].id,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
