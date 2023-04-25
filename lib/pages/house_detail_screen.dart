import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HouseDetailScreen extends StatelessWidget {
  final String houseId;

  const HouseDetailScreen({Key? key, required this.houseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('House Detail'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('houses')
              .doc(houseId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
            //final description = house.get('description');
            final latLng = house.get('latlng');

            // Return a widget that displays the house details
            return Container(
              child: Column(
                children: [
                  Text(title),
                  // Text(description),
                  Text('Rooms: $nRooms'),
                  Text('Bathrooms: $nBathroom'),
                  Text('Price: $price'),
                ],
              ),
            );
          },
        ));
  }
}
