import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobapp/pages/messages_page.dart';
import 'package:jobapp/pages/profile_page.dart';
import 'package:jobapp/pages/map_page.dart';
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
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        leading: _currentIndex == 0
            ? Container(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.map_outlined,
                          color: Colors.grey[600],
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return MapPage();
                            },
                          ));
                        },
                      ),
                    ),
                  ],
                ),
              )
            : null,
        actions: _currentIndex == 0
            ? <Widget>[
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
                                return MapPage();
                              },
                            ));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
      body: IndexedStack(index: _currentIndex, children: [
        // Add the StreamBuilder wrapped in a Center widget
        Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('houses').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final houses = snapshot.data!.docs;
              return ListView.builder(
                itemCount: houses.length,
                itemBuilder: (BuildContext context, int index) {
                  final house = houses[index];
                  final imageUrl = house.get('image_url');
                  final nRooms = house.get('n_rooms');
                  final nBathroom = house.get('n_bathroom');
                  final price = house.get('price');
                  final title = house.get('title');
                  final latLng = house.get('latlng');
                  return Card(
                    child: InkWell(
                      onTap: () {
                        // Navigate to a detail screen or show a dialog with more information
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                          leading: SizedBox(
                            width: 96,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$nRooms rooms, $nBathroom bathrooms'),
                              SizedBox(height: 4),
                              Text('Price: $price\€'),
                            ],
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
        Tinder(),
        Messages(),
        Column(
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
        Profile(),
      ]),
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
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
