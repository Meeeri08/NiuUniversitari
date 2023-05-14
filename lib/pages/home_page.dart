import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jobapp/pages/filter_screen.dart';
import 'package:jobapp/pages/house_detail_screen.dart';
import 'package:jobapp/pages/profile_page.dart';
import 'package:jobapp/pages/map_page.dart';
import 'package:jobapp/pages/tinder.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'messages_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<DocumentSnapshot>? filteredHouses;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Set the gradient color here
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        leading: _currentIndex == 0
            ? Container(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          List<DocumentSnapshot>? result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return FilterScreen(
                                onFilterApplied: (houses) {
                                  setState(() {
                                    filteredHouses = houses;
                                  });
                                },
                              );
                            }),
                          );
                          if (result != null) {
                            setState(() {
                              filteredHouses = result;
                            });
                          }
                        },
                        child: Icon(
                          Icons.filter_list_sharp,
                          color: Colors.grey[600],
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
        actions: _currentIndex == 0
            ? <Widget>[
                Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return const MapPage();
                              }),
                            );
                          },
                          child: Icon(
                            Icons.search_sharp,
                            color: Colors.grey[600],
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFfafafa),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: IndexedStack(index: _currentIndex, children: [
          // Add the StreamBuilder wrapped in a Center widget
          Center(
            child: StreamBuilder<QuerySnapshot>(
              stream: (filteredHouses?.isNotEmpty == true)
                  ? FirebaseFirestore.instance
                      .collection('houses')
                      .where(FieldPath.documentId,
                          whereIn: filteredHouses!.map((e) => e.id).toList())
                      .snapshots()
                  : FirebaseFirestore.instance.collection('houses').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final houses = snapshot.data!.docs;

                if (houses.isEmpty) {
                  return Center(child: Text('No houses match the filters'));
                }

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

                    return GestureDetector(
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HouseDetailScreen(houseId: house.id),
                              ),
                            );
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
                                  const SizedBox(height: 4),
                                  Text('Price: $price€'),
                                ],
                              ),
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

          const Tinder(),
          const Messages(),

          const Profile(),
        ]),
      ),
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: Colors.white,
          animationDuration: const Duration(milliseconds: 400),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            Icon(
              Icons.home,
              color:
                  _currentIndex == 0 ? Color(0xFF1FA29E) : Colors.grey.shade300,
            ),
            Icon(
              Icons.favorite,
              color:
                  _currentIndex == 1 ? Color(0xFF1FA29E) : Colors.grey.shade300,
            ),
            Icon(
              Icons.message_outlined,
              color:
                  _currentIndex == 2 ? Color(0xFF1FA29E) : Colors.grey.shade300,
            ),
            Icon(
              Icons.person,
              color:
                  _currentIndex == 3 ? Color(0xFF1FA29E) : Colors.grey.shade300,
            ),
          ]),
    ));
  }
}
