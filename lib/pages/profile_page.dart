import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobapp/pages/home_page.dart';
import 'package:jobapp/pages/tinder.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser!;

  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(backgroundColor: Color.fromARGB(236, 236, 236, 236)));
  }
}
