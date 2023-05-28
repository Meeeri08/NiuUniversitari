import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobapp/pages/featured_page.dart';
import 'package:jobapp/pages/filter_screen.dart';
import 'package:jobapp/pages/house_detail_screen.dart';
import 'package:jobapp/pages/map_page.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot>? filteredHouses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Container(
                height: MediaQuery.of(context).padding.top + kToolbarHeight,
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.list_sharp),
                      color: Colors.grey.shade600,
                      iconSize: 30,
                      onPressed: () async {
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
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: Colors.grey.shade600,
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MapPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Troba el teu',
                            style: GoogleFonts.dmSans(
                              fontSize: 30,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'habitatge ideal',
                            style: GoogleFonts.dmSans(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xff25262b),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: (filteredHouses?.isNotEmpty == true)
                    ? FirebaseFirestore.instance
                        .collection('houses')
                        .where(FieldPath.documentId,
                            whereIn: filteredHouses!.map((e) => e.id).toList())
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final houses = snapshot.data!.docs;

                  if (filteredHouses?.isEmpty == true) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: AlertDialog(
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
                      ),
                    );
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: ListView.builder(
                      itemCount: houses.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final house = houses[index];
                        final title = house['title'];
                        final zone = house['barri'];
                        final price = house['price'].toString();
                        final imageUrl = house['image_url'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HouseDetailScreen(
                                  houseId: house.id,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.56,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.21,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      title,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 5.0),
                                        child: Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '  $zone',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          price,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          ' € / mes',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Propietats Estrella',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff25262b),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Featured(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            'Veure tots',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: const Color(0xff25262b),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: const Color(0xff25262b),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 140,
                width: MediaQuery.of(context).size.width * 1,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('houses')
                      .where('featured', isEqualTo: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final featuredHouses = snapshot.data!.docs;

                    final random = Random();
                    final randomIndex = random.nextInt(featuredHouses.length);
                    final randomHouse = featuredHouses[randomIndex];
                    final title = randomHouse['title'];
                    final imageUrl = randomHouse['image_url'];
                    final zone = randomHouse['barri'];
                    final price = randomHouse['price'].toString();
                    final n_rooms = randomHouse['n_rooms'].toString();
                    final n_bathrooms = randomHouse['n_bathroom'].toString();

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HouseDetailScreen(houseId: randomHouse.id),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    imageUrl,
                                    width: 140,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xff25262b),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            ' $zone',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.single_bed_outlined,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            ' $n_rooms habitació',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.bathtub_outlined,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            ' $n_bathrooms bany',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Text(
                                            price,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            ' € / mes',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ])));
  }
}
