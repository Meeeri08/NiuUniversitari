import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HouseDetailScreen extends StatefulWidget {
  final String houseId;

  const HouseDetailScreen({Key? key, required this.houseId}) : super(key: key);

  @override
  _HouseDetailScreenState createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends State<HouseDetailScreen> {
  late final LatLng _initialLatLng;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

    // Initialize the initial LatLng value to the location of the house
    FirebaseFirestore.instance
        .collection('houses')
        .doc(widget.houseId)
        .get()
        .then((snapshot) {
      final latLng = snapshot.get('latlng');
      final lat = latLng.latitude;
      final lng = latLng.longitude;
      setState(() {
        _initialLatLng = LatLng(lat, lng);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('House Detail'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('houses')
                .doc(widget.houseId)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              final house = snapshot.data!;
              final imageUrl = house.get('image_url');
              final nRooms = house.get('n_rooms');
              final nBathroom = house.get('n_bathroom');
              final price = house.get('price');
              final title = house.get('title');
              final latLng = house.get('latlng');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition:
                              CameraPosition(target: _initialLatLng, zoom: 15),
                          onMapCreated: (GoogleMapController controller) {
                            if (_mapController == null) {
                              _mapController = controller;
                            }
                          },
                          markers: {
                            Marker(
                              markerId: MarkerId(widget.houseId),
                              position: _initialLatLng,
                              infoWindow: InfoWindow(title: title),
                            ),
                          },
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$$price',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Per Month',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
  }
}
