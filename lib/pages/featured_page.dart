import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobapp/pages/house_detail_screen.dart';

class Featured extends StatefulWidget {
  @override
  _FeaturedState createState() => _FeaturedState();
}

class _FeaturedState extends State<Featured> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Habitatges Estrella',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xff25262b),
            ),
          ),
          iconTheme: IconThemeData(
            color: Color(0xff25262b),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffffffff),
                Color(0xfff9f9fa),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('houses')
                .where('featured', isEqualTo: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

              return ListView.builder(
                shrinkWrap: true,
                itemCount: featuredHouses.length,
                itemBuilder: (BuildContext context, int index) {
                  final randomHouse = featuredHouses[index];
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
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Container(
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
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
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
                                                color: const Color(0xff25262b),
                                              ),
                                            ),
                                            Text(
                                              ' € / mes',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: const Color(0xff25262b),
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
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ));
  }
}
