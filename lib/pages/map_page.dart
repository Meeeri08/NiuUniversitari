import 'dart:ui' as ui;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobapp/pages/house_detail_screen.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;
import 'package:intl/intl.dart'; // Import the intl package

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
    final textPainter =
        TextPainter(text: textSpan, textDirection: ui.TextDirection.ltr);
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
                icon: const Icon(Icons.arrow_back_ios),
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

    final nBathrooms = doc.get('n_bathroom');
    final nRooms = doc.get('n_rooms');

    final timestamp = doc.get('datainici') as Timestamp;
    final date = DateFormat('dd MMM').format(timestamp.toDate());

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
                          height: 160,
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
                                    color: Color(0xff25262b),
                                  ),
                                ),
                                Text(
                                  doc.get('price').toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xff25262b),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.king_bed,
                                      color: Color(0xff25262b),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "$nRooms room",
                                      selectionColor: Color(0xff25262b),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.bathtub,
                                        color: Color(0xff25262b)),
                                    SizedBox(width: 5),
                                    Text(
                                      "$nBathrooms bathroom",
                                      selectionColor: Color(0xff25262b),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Container(
                                height: 30,
                                width: 250,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    color: Colors.grey.shade300,
                                    child: Center(
                                      child: Text(
                                        "Disponible a partir de: $date",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
