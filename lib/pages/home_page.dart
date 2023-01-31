import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobapp/pages/messages_page.dart';
import 'package:jobapp/pages/profile_page.dart';
import 'package:jobapp/pages/settings_page.dart';
import 'package:jobapp/pages/tinder.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _currentIndex = 0;

  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
      backgroundColor: Color.fromARGB(236, 236, 236, 236),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Container(
              child: Icon(
                Icons.map_outlined,
                color: Colors.grey[600],
                size: 30,
              ),
            ),
            onPressed: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => MapPage(),
              // ));
            },
          ),
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: Colors.grey[600],
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return SettingsPage();
                        },
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
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
          Tinder(),
          Messages(),
          Profile(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Color.fromARGB(236, 236, 236, 236),
          color: Colors.deepPurple.shade100,
          animationDuration: Duration(milliseconds: 400),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            Icon(
              Icons.home,
              color: Colors.white,
            ),
            Icon(
              Icons.favorite,
              color: Colors.white,
            ),
            Icon(
              Icons.message_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.person,
              color: Colors.white,
            ),
          ]),
    ));
  }
}
