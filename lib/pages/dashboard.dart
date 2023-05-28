import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
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
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                            fontSize: 32,
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
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
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
                  : FirebaseFirestore.instance.collection('houses').snapshots(),
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
                    padding: const EdgeInsets.only(bottom: 300.0),
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
                  height: MediaQuery.of(context).size.height * 0.36,
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
                          width: MediaQuery.of(context).size.width * 0.6,
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
                                    height: MediaQuery.of(context).size.height *
                                        0.22,
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
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: const Icon(
                                        Icons.location_on,
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
          ],
        ),
      ),
    );
  }
}
