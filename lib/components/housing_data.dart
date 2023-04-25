import 'package:cloud_firestore/cloud_firestore.dart';

class HousingData {
  final String? id;
  final String title;
  final String image_url;
  final int n_bathroom;
  final int n_room;
  final int price;
  final double latitude;
  final double longitude;

  const HousingData({
    this.id,
    required this.title,
    required this.image_url,
    required this.n_bathroom,
    required this.n_room,
    required this.price,
    required this.latitude,
    required this.longitude,
  });

  toJson() {
    return {
      "Title": title,
      "ImageUrl": image_url,
      "NumberOfBathroom": n_bathroom,
      "NumberOfRoom": n_room,
      "Price": price,
      "Latitude": latitude,
      "Longitude": longitude
    };
  }

  factory HousingData.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return HousingData(
        id: document.id,
        title: data["title"],
        image_url: data["image_url"],
        n_bathroom: data["n_bathroom"],
        n_room: data["n_room"],
        price: data["price"],
        latitude: data["latitude"],
        longitude: data["longitude"]);
  }
}
