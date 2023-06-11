import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobapp/pages/chat_page.dart';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HouseDetailScreen extends StatefulWidget {
  final String houseId;

  const HouseDetailScreen({Key? key, required this.houseId}) : super(key: key);

  @override
  _HouseDetailScreenState createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends State<HouseDetailScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  GoogleMapController? _mapController;
  LatLng? _initialLatLng;
  List<String> imageUrls = [];
  int price = 0;
  late BitmapDescriptor _markerIcon;
  bool isSaved = false;
  late String userId = '';

  int index = 0;
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

  void toggleBookmark(String houseId) {
    final CollectionReference savedHousesRef =
        FirebaseFirestore.instance.collection('savedhouses');

    savedHousesRef.doc(userId).get().then((docSnapshot) {
      if (docSnapshot.exists) {
        // El documento del usuario ya existe en la colección
        // Se obtiene el array de ids de las houses bookmarked
        List<dynamic> houseIds = docSnapshot.get('houseIds');

        if (isSaved) {
          // Agregar el houseId al array si aún no está presente
          if (!houseIds.contains(houseId)) {
            houseIds.add(houseId);
          }
        } else {
          // Eliminar el houseId del array
          houseIds.remove(houseId);
        }

        // Actualizar el array en el documento
        savedHousesRef.doc(userId).update({'houseIds': houseIds});
      } else {
        // El documento del usuario no existe en la colección
        // Crear un nuevo documento con el userId y el array de houseIds
        List<String> houseIds = [houseId];

        savedHousesRef.doc(userId).set({'houseIds': houseIds});
      }
    });
  }

  void redirectToChatScreen(String propietariId) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String currentUserId = user?.uid ?? '';

    if (currentUserId == propietariId) {
      // Display a message that you can't chat with yourself
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No pots xatejar amb tu mateix!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      final participants = [propietariId, currentUserId];
      participants.sort(); // Sort the participants' IDs alphabetically
      final chatId = participants.join('_'); // Generate a unique chat ID

      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();

      if (chatDoc.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              propietariId: propietariId,
              chatId: chatId,
            ),
          ),
        );
      } else {
        // Create a new chat
        await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
          'users': participants,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              propietariId: propietariId,
              chatId: chatId,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error retrieving chat document: $e');
    }
  }

  @override
  void initState() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      userId = user.uid;

      final CollectionReference savedHousesRef =
          FirebaseFirestore.instance.collection('savedhouses');
      savedHousesRef.doc(userId).get().then((docSnapshot) {
        if (docSnapshot.exists) {
          // El documento del usuario ya existe en la colección
          List<dynamic> houseIds = docSnapshot.get('houseIds');

          setState(() {
            isSaved = houseIds.contains(widget.houseId);
          });
        }
      });
    }

    _loadMarkerIcon();

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
            Color(0xfff9f9fa),
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
                              color: Color(0xff25262b),
                            ),
                          ),
                          Positioned(
                            right: 3,
                            child: Text(
                              '€',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff25262b),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        ' / mes',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Color(0xff25262b),
                        ),
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
                          return InkWell(
                            onTap: () {
                              setState(() {
                                isSaved = !isSaved;
                              });

                              toggleBookmark(widget.houseId);
                            },
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              size: 26,
                              color: Color(0xff25262b),
                            ),
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
                      final imageUrl = house['image_url'];
                      final propietariUrl = house['propietari_url'];
                      final nRooms = house['n_rooms'];
                      final nBathroom = house['n_bathroom'];
                      final price = house['price'];
                      final title = house['title'];
                      final propietari = house['propietari_id'];
                      final latLng = house['latlng'];
                      final description = house['description'];
                      final dimensions = house['dimensions'];
                      final imatges = house['imatges'];
                      final imageUrls =
                          imatges != null && imatges is List<dynamic>
                              ? List<String>.from(imatges)
                              : [];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(propietari)
                            .get(),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> userSnapshot,
                        ) {
                          if (userSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${userSnapshot.error}'));
                          }
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final user = userSnapshot.data!;
                          final userName = user.get('name') as String;
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) {
                                                    return Scaffold(
                                                      backgroundColor:
                                                          Colors.black,
                                                      body: Stack(
                                                        children: [
                                                          Positioned.fill(
                                                            child: PhotoView(
                                                              imageProvider:
                                                                  NetworkImage(
                                                                imageUrls[
                                                                    index],
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: MediaQuery.of(
                                                                        context)
                                                                    .padding
                                                                    .top +
                                                                16,
                                                            left: 16,
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .arrow_back,
                                                                color: Colors
                                                                    .white,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          Icon(Icons.bathtub_outlined,
                                              size: 23),
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
                                          Icon(Icons.square_foot_outlined,
                                              size: 23),
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
                                            color: Color.fromARGB(
                                                146, 224, 224, 224),
                                            height: 30,
                                          ),
                                          Container(
                                            height: 50,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          propietariUrl),
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
                                                      userName,
                                                      style: GoogleFonts.dmSans(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xff25262b),
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
                                                          BorderRadius.circular(
                                                              13.0),
                                                      child: Container(
                                                        height: 40,
                                                        width: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(13),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.05),
                                                              blurRadius: 4.0,
                                                              offset:
                                                                  Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .chat_bubble_outline_rounded,
                                                            color: Color(
                                                                0xff25262b),
                                                          ),
                                                          onPressed: () {
                                                            redirectToChatScreen(
                                                                propietari);
                                                          },
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
                                                      BorderRadius.circular(
                                                          13.0),
                                                  child: Container(
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              13.0),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.05),
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
                                            color: Color.fromARGB(
                                                146, 224, 224, 224),
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
                                            target: _initialLatLng ??
                                                const LatLng(0, 0),
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
                                                    markerId: MarkerId(
                                                        widget.houseId),
                                                    position: _initialLatLng ??
                                                        const LatLng(0, 0),
                                                    icon: _markerIcon,
                                                    anchor:
                                                        const Offset(0.5, 0.5),
                                                  ),
                                                }
                                              : {},
                                        ),
                                      ), // Divider
                                      const SizedBox(height: 5),

                                      Divider(
                                        thickness: 1,
                                        color:
                                            Color.fromARGB(146, 224, 224, 224),
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
                                        animationDuration:
                                            const Duration(seconds: 2),
                                        linkEllipsis: false,
                                        textAlign: TextAlign.justify,
                                        linkStyle: const TextStyle(
                                            decoration:
                                                TextDecoration.underline),
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
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
