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
      // bottomNavigationBar:
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          floating: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          leadingWidth: 90,
          expandedHeight: _currentIndex == 0 ? 240.0 : 10,
          flexibleSpace: _currentIndex == 0
              ? FlexibleSpaceBar(
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: _currentIndex == 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30, left: 30),
                          child: Text(
                            'Troba el teu',
                            style: GoogleFonts.dmSans(
                              fontSize: 36,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _currentIndex == 0,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, bottom: 20),
                          child: Text(
                            'habitatge ideal',
                            style: GoogleFonts.dmSans(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff25262b),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          leading: _currentIndex == 0
              ? SizedBox(
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
                          decoration: const BoxDecoration(),
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

        SliverFillRemaining(
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

                          if (filteredHouses?.isEmpty == true) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'No hi ha cap resultat per a la teva cerca.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    setState(() {
                                      filteredHouses = null;
                                    });
                                  },
                                ),
                              ],
                            );
                          }

                          return SizedBox(
                            width: 400, // Ajusta el ancho del ListView aquí
                            child: ListView.builder(
                              padding: EdgeInsets.only(bottom: 200),
                              // physics: BouncingScrollPhysics(),
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: houses.length,
                              itemBuilder: (BuildContext context, int index) {
                                final house = houses[index];
                                final imageUrl = house.get('image_url');
                                final nRooms = house.get('n_rooms');
                                final nBathroom = house.get('n_bathroom');
                                final price = house.get('price');
                                final title = house.get('title');
                                final latLng = house.get('latlng');
                                final barri = house.get('barri');

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: GestureDetector(
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 130,
                                                height: 130,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  image: DecorationImage(
                                                    image:
                                                        NetworkImage(imageUrl),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    style: GoogleFonts.dmSans(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Color(0xff25262b),
                                                    ),
                                                  ),
                                                  SizedBox(height: 15),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .location_on_outlined,
                                                        color: Colors
                                                            .grey.shade500,
                                                        size: 14,
                                                      ),
                                                      Text(
                                                        '  $barri',
                                                        style:
                                                            GoogleFonts.dmSans(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey.shade500,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.bed_rounded,
                                                        color: Colors
                                                            .grey.shade500,
                                                        size: 14,
                                                      ),
                                                      Text(
                                                        '  $nRooms rooms',
                                                        style:
                                                            GoogleFonts.dmSans(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey.shade500,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      SizedBox(width: 25),
                                                      Icon(
                                                        Icons.bathtub_outlined,
                                                        color: Colors
                                                            .grey.shade500,
                                                        size: 14,
                                                      ),
                                                      Text(
                                                        '  $nBathroom Lavabo',
                                                        style:
                                                            GoogleFonts.dmSans(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey.shade500,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 30),
                                                  Text(
                                                    ' $price€ /mes',
                                                    style: GoogleFonts.dmSans(
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
                child: CurvedNavigationBar(
                  height: 50,
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
            ],
          ),
        ),

        //  Sliver
      ]),
    );
  }
}
