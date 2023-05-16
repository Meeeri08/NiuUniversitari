import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_view/photo_view.dart';

class HouseDetailScreen extends StatefulWidget {
  final String houseId;

  const HouseDetailScreen({Key? key, required this.houseId}) : super(key: key);

  @override
  _HouseDetailScreenState createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends State<HouseDetailScreen> {
  GoogleMapController? _mapController;
  LatLng? _initialLatLng;
  List<String> imageUrls = [];
  int price = 0;
  late BitmapDescriptor _markerIcon;
  Future<void> _loadMarkerIcon() async {
    final BitmapDescriptor markerIcon = await _createMarkerIcon();

    setState(() {
      _markerIcon = markerIcon;
    });
  }

  Future<BitmapDescriptor> _createMarkerIcon() async {
    const String markerAssetPath = 'assets/marker_icon.png';
    final ByteData markerByteData = await rootBundle.load(markerAssetPath);
    final Uint8List markerIconBytes = markerByteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(markerIconBytes);
  }

  @override
  void initState() {
    _loadMarkerIcon();
    bool isSaved = false;

    super.initState();
    // Initialize the initial LatLng value to the location of the house
    FirebaseFirestore.instance
        .collection('houses')
        .doc(widget.houseId)
        .get()
        .then((snapshot) {
      final latLngData = snapshot.get('latlng');
      print('latLngData type: ${latLngData.runtimeType}');
      if (latLngData is GeoPoint) {
        final lat = latLngData.latitude;
        final lng = latLngData.longitude;
        setState(() {
          _initialLatLng = LatLng(lat, lng);
          price = snapshot.get('price');
        });
      } else {
        print('Error: Invalid data type for latLng field.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xffffffff),
            Color(0xffffffff),
            Color.fromARGB(255, 237, 237, 239),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: Container(
          height: 80,
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${price.toString()}   ',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Positioned(
                            right: 3,
                            child: Text(
                              '€',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ' / mes',
                        style: GoogleFonts.dmSans(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                  width: 150,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1FA29E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black,
                    ),
                    child: Text(
                      "M'interessa",
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(width: 14),
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      iconSize: 22,
                      color: Color(0xff25262b),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Detalls',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff25262b),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                            ),
                            iconSize: 26,
                            color: Color(0xff25262b),
                            onPressed: () {
                              setState(() {
                                isSaved = !isSaved;
                              });

                              // Handle favorite button press
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('houses')
                      .doc(widget.houseId)
                      .snapshots(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final house = snapshot.data!;
                    final imageUrl = house.get('image_url');
                    final propietariUrl = house.get('propietari_url');
                    final nRooms = house.get('n_rooms');
                    final nBathroom = house.get('n_bathroom');
                    final price = house.get('price');
                    final title = house.get('title');
                    final propietari = house.get('propietari');
                    final latLng = house.get('latlng');
                    final description = house.get('description');
                    final dimensions = house.get('dimensions');
                    final imatges = house.get('imatges');
                    final imageUrls =
                        imatges != null && imatges is List<dynamic>
                            ? List<String>.from(imatges)
                            : [];

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 190,
                            child: PageView.builder(
                              itemCount: imageUrls.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return Scaffold(
                                                backgroundColor: Colors.black,
                                                body: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: PhotoView(
                                                        imageProvider:
                                                            NetworkImage(
                                                          imageUrls[index],
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top:
                                                          MediaQuery.of(context)
                                                                  .padding
                                                                  .top +
                                                              16,
                                                      left: 16,
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.arrow_back,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 18, left: 18),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrls[index],
                                            fit: BoxFit.cover,
                                            width: 340,
                                            height: 190,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color(0xff25262b),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.bed_outlined, size: 23),
                                    SizedBox(width: 8),
                                    Text(
                                      '$nRooms Habitacio',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        //fontWeight: FontWeight.bold,
                                        color: Color(0xff25262b),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(Icons.bathtub_outlined, size: 23),
                                    SizedBox(width: 8),
                                    Text(
                                      '$nBathroom Lavabo',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        //fontWeight: FontWeight.bold,
                                        color: Color(0xff25262b),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(Icons.square_foot_outlined, size: 23),
                                    SizedBox(width: 8),
                                    Text(
                                      '$dimensions m\u00B2',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        //fontWeight: FontWeight.bold,
                                        color: Color(0xff25262b),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Divider(
                                      thickness: 1,
                                      color: Color.fromARGB(146, 224, 224, 224),
                                      height: 30,
                                    ),
                                    Container(
                                      height: 50,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image:
                                                    NetworkImage(propietariUrl),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                propietari,
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 14,
                                                  color: Color(0xff25262b),
                                                ),
                                              ),
                                              Text(
                                                'Propietari',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  // Chat button action
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(13.0),
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            13),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.05),
                                                        blurRadius: 4.0,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .chat_bubble_outline_rounded,
                                                    color: Color(0xff25262b),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: () {
                                              // Phone call button action
                                            },
                                            borderRadius:
                                                BorderRadius.circular(13.0),
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(13.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 4.0,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.phone_outlined,
                                                color: Color(0xff25262b),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      thickness: 1,
                                      color: Color.fromARGB(146, 224, 224, 224),
                                      height: 30,
                                    ),
                                  ],
                                ),

                                const Text(
                                  'Ubicació',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xff25262b),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  width: double.infinity,
                                  height: 120,
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target:
                                          _initialLatLng ?? const LatLng(0, 0),
                                      zoom: 15,
                                    ),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      _mapController ??= controller;
                                    },
                                    myLocationButtonEnabled: false,
                                    markers: _markerIcon != null
                                        ? {
                                            Marker(
                                              markerId:
                                                  MarkerId(widget.houseId),
                                              position: _initialLatLng ??
                                                  const LatLng(0, 0),
                                              icon: _markerIcon,
                                              anchor: const Offset(0.5, 0.5),
                                              infoWindow:
                                                  InfoWindow(title: title),
                                            ),
                                          }
                                        : {},
                                  ),
                                ), // Divider
                                const SizedBox(height: 5),

                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(146, 224, 224, 224),
                                  height: 30,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'Descripció',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xff25262b),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ExpandableText(
                                  description,
                                  expandText: 'Llegeix Més',
                                  collapseText: 'Llegeix Menys',
                                  linkColor: const Color(0xff25262b),
                                  maxLines: 2,
                                  animation: true,
                                  animationDuration: const Duration(seconds: 2),
                                  linkEllipsis: false,
                                  textAlign: TextAlign.justify,
                                  linkStyle: const TextStyle(
                                      decoration: TextDecoration.underline),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff25262b),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
