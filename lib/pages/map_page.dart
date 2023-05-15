import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobapp/pages/house_detail_screen.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

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
  String _mapStyle = '';

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyle = string;
    });

    super.initState();
  }

  Future<BitmapDescriptor> _createMarkerIcon(String price) async {
    const String markerAssetPath = 'assets/marker_icon.png';
    final ByteData markerByteData = await rootBundle.load(markerAssetPath);
    final Uint8List markerIconBytes = markerByteData.buffer.asUint8List();

    const Size markerSize = Size(20.0, 40.0);

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Rect markerRect = Offset.zero & markerSize;
    final Paint markerPaint = Paint()..color = Colors.blue;
    canvas.drawImageRect(
      await decodeImageFromList(markerIconBytes),
      Rect.fromLTRB(0, 0, markerSize.width, markerSize.height),
      markerRect,
      markerPaint,
    );

    const textStyle = TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: price,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textOffset = Offset(
      (markerSize.width - textPainter.width) / 2,
      (markerSize.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);

    final image = await pictureRecorder.endRecording().toImage(
          markerSize.width.toInt(),
          markerSize.height.toInt(),
        );

    final Uint8List markerBytes = markerByteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(markerBytes);
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
              _googleMapController.setMapStyle(_mapStyle);

              _addMarkersToMap();
            },
            markers: _markers,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
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
    final markerFutures = houses.docs.map((doc) => _createMarker(doc)).toList();
    final markers = await Future.wait(markerFutures);
    setState(() {
      _markers = markers.toSet();
    });
  }

  Future<Marker> _createMarker(QueryDocumentSnapshot doc) async {
    final price = doc.get('price').toString();
    final markerIcon = await _createMarkerIcon(price);

    return Marker(
      markerId: MarkerId(doc.id),
      icon: markerIcon,
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
                    builder: (context) => HouseDetailScreen(houseId: doc.id),
                  ),
                );
              },
              child: SizedBox(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  doc['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  doc.get('price').toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.king_bed),
                                    SizedBox(width: 5),
                                    Text("3 bedrooms"),
                                  ],
                                ),
                                Row(
                                  children: const [
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
    );
  }
}
