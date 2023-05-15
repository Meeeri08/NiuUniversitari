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
  String _mapStyle = '';

  @override
  void initState() {
    rootBundle.loadString('assets/map_style2.json').then((string) {
      _mapStyle = string;
    });

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
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                    ), // Move the top arrow a bit to the right
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      iconSize: 20,
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
                    SizedBox(
                      width: 48,
                      height: 40,
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
                    final nRooms = house.get('n_rooms');
                    final nBathroom = house.get('n_bathroom');
                    final price = house.get('price');
                    final title = house.get('title');
                    final latLng = house.get('latlng');
                    final description = house.get('description');
                    final dimensions = house.get('dimensions');
                    final imatges = house.get('imatges');
                    final imageUrls =
                        imatges != null && imatges is List<dynamic>
                            ? List<String>.from(imatges)
                            : [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 200,
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
                                                    top: MediaQuery.of(context)
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
                                                        Navigator.pop(context);
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
                                        borderRadius: BorderRadius.circular(8),
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
                                    '$dimensions m²',
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
                                            color: Colors.grey[300],
                                          ),
                                          // child: Image.asset(
                                          //     'your_image_path.png'), // Replace with your image
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Full Name',
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
                                        IconButton(
                                          onPressed: () {
                                            // Chat button action
                                          },
                                          icon: Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            color: Color(0xff25262b),
                                            // Add desired gradient or shadow to the icon
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            // Phone call button action
                                          },
                                          icon: Icon(
                                            Icons.phone_outlined,
                                            color: Color(0xff25262b),
                                            // Add desired gradient or shadow to the icon
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
                                height: 150,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target:
                                        _initialLatLng ?? const LatLng(0, 0),
                                    zoom: 15,
                                  ),
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                    _mapController!.setMapStyle(_mapStyle);
                                  },
                                  myLocationButtonEnabled: false,
                                  markers: {
                                    Marker(
                                      markerId: MarkerId(widget.houseId),
                                      position:
                                          _initialLatLng ?? const LatLng(0, 0),
                                      icon:
                                          BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueViolet,
                                      ),
                                      anchor: const Offset(0.3, 0.3),
                                      infoWindow: InfoWindow(title: title),
                                    ),
                                  },
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
                    );
                  },
                ),
                const SizedBox(height: 80),
                Container(
                    width: double.infinity,
                    color: Colors
                        .red, // Personaliza el color según tus necesidades
                    child: Center(
                      child: Text(
                        'Container',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
