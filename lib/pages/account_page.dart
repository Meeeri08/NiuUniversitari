import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobapp/pages/profile_page.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Compte',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xff25262b),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final users = snapshot.data!.docs;

          // Assuming you have only one user document, you can access the first document like this
          final user = users.first;

          final imageUrl = user['imageUrl'];
          final name = user['name'];

          return Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              // Rest of your UI code
              SizedBox(height: 20),
              Row(
                children: [
                  // Rest of your code
                ],
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text('Componente 1'),
                onTap: () {
                  // Lógica para ir a la pantalla del Componente 1
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );

                  // Rest of your code
                },
              ),
              ListTile(
                title: Text('Componente 2'),
                onTap: () {
                  // Rest of your code
                },
              ),
              ListTile(
                title: Text('Componente 3'),
                onTap: () {
                  // Rest of your code
                },
              ),
              ListTile(
                title: Text('Componente 4'),
                onTap: () {
                  // Rest of your code
                },
              ),
              ListTile(
                title: Text('Componente 5'),
                onTap: () {
                  // Rest of your code
                },
              ),
              IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.login_outlined),
                color: const Color(0xff25262b),
                tooltip: 'Cerrar sesión',
              ),
            ],
          );
        },
      ),
    );
  }
}
