import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobapp/pages/house_detail_screen.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(41.38859447609031, 2.1686747276829004),
    zoom: 13,
  );
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late GoogleMapController _googleMapController;
  Set<Marker> _markers = {};

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _googleMapController = controller;
              _addMarkersToMap();
            },
            markers: _markers,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMarkersToMap() async {
    final houses = await firestore.collection('houses').get();
    final markers = houses.docs
        .map((doc) => Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(
                doc['latlng'].latitude,
                doc['latlng'].longitude,
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HouseDetailScreen(houseId: doc.id),
                          ),
                        );
                      },
                      child: Container(
                        height: 300,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Image.network(
                                  doc['image_url'],
                                  width: MediaQuery.of(context).size.width,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          doc['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          doc.get('price').toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.king_bed),
                                            SizedBox(width: 5),
                                            Text("3 bedrooms"),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.bathtub),
                                            SizedBox(width: 5),
                                            Text("2 bathrooms"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ))
        .toSet();
    setState(() {
      _markers = markers;
    });
  }
}
