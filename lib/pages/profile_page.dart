import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Color.fromARGB(236, 236, 236, 236),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Has iniciat sessió com a: ' + user.email!),
                  MaterialButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      color: Colors.deepPurple[200],
                      child: Text('Tanca la sessió'))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
