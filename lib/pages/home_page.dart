import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
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
                            List<DocumentSnapshot>? result =
                                await Navigator.push(
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
                          decoration: BoxDecoration(),
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
                              Icons.search,
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffffffff),
                  Color.fromARGB(255, 237, 237, 239),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  'Find your',
                  style: GoogleFonts.dmSans(
                    fontSize: 36,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  'best property',
                  style: GoogleFonts.dmSans(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff25262b),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: [
                          Center(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: (filteredHouses?.isNotEmpty == true)
                                  ? FirebaseFirestore.instance
                                      .collection('houses')
                                      .where(FieldPath.documentId,
                                          whereIn: filteredHouses!
                                              .map((e) => e.id)
                                              .toList())
                                      .snapshots()
                                  : FirebaseFirestore.instance
                                      .collection('houses')
                                      .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final houses = snapshot.data!.docs;

                                if (houses.isEmpty) {
                                  return Center(
                                    child: Text('No houses match the filters'),
                                  );
                                }

                                return Container(
                                  width:
                                      350, // Ajusta el ancho del ListView aquí
                                  child: ListView.builder(
                                    itemCount: houses.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final house = houses[index];
                                      final imageUrl = house.get('image_url');
                                      final nRooms = house.get('n_rooms');
                                      final nBathroom = house.get('n_bathroom');
                                      final price = house.get('price');
                                      final title = house.get('title');
                                      final latLng = house.get('latlng');

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: GestureDetector(
                                          child: Card(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HouseDetailScreen(
                                                      houseId: house.id,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 140,
                                                      height: 140,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              imageUrl),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          title,
                                                          style: GoogleFonts
                                                              .dmSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: Color(
                                                                      0xff25262b)),
                                                        ),
                                                        Text(
                                                          title,
                                                          style: GoogleFonts
                                                              .dmSans(
                                                            fontSize:
                                                                14, // Ajusta el tamaño de fuente aquí
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.bed_rounded,
                                                              color: Colors.grey
                                                                  .shade500,
                                                              size: 14,
                                                            ),
                                                            Text(
                                                              '  $nRooms rooms',
                                                              style: GoogleFonts
                                                                  .dmSans(
                                                                      fontSize:
                                                                          12, // Ajusta el tamaño de fuente aquí
                                                                      color: Colors
                                                                          .grey
                                                                          .shade500),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Icon(
                                                              Icons
                                                                  .bathtub_outlined,
                                                              color: Colors.grey
                                                                  .shade500,
                                                              size: 14,
                                                            ),
                                                            Text(
                                                              '  $nBathroom  Lavabo',
                                                              style: GoogleFonts
                                                                  .dmSans(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade500),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Price: $price€',
                                                          style: GoogleFonts
                                                              .dmSans(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const Tinder(),
                          const Messages(),
                          const Profile(),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: CurvedNavigationBar(
                          backgroundColor: Colors.transparent,
                          animationDuration: const Duration(milliseconds: 600),
                          index: _currentIndex,
                          onTap: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          items: [
                            Icon(
                              Icons.home,
                              color: _currentIndex == 0
                                  ? Color(0xFF1FA29E)
                                  : Colors.grey.shade300,
                            ),
                            Icon(
                              Icons.favorite,
                              color: _currentIndex == 1
                                  ? Color(0xFF1FA29E)
                                  : Colors.grey.shade300,
                            ),
                            Icon(
                              Icons.message_outlined,
                              color: _currentIndex == 2
                                  ? Color(0xFF1FA29E)
                                  : Colors.grey.shade300,
                            ),
                            Icon(
                              Icons.person,
                              color: _currentIndex == 3
                                  ? Color(0xFF1FA29E)
                                  : Colors.grey.shade300,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}
