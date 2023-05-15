import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterScreen extends StatefulWidget {
  final Function(List<DocumentSnapshot>?) onFilterApplied;

  const FilterScreen({Key? key, required this.onFilterApplied})
      : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int minPrice = 0;
  int maxPrice = 2000;
  int minRooms = 0;
  int maxRooms = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Price Range'),
            subtitle: RangeSlider(
              values: RangeValues(minPrice.toDouble(), maxPrice.toDouble()),
              min: 0,
              max: 2000,
              divisions: 100,
              onChanged: (RangeValues values) {
                setState(() {
                  minPrice = values.start.toInt();
                  maxPrice = values.end.toInt();
                });
              },
            ),
          ),
          ListTile(
            title: Text('Number of Rooms'),
            subtitle: RangeSlider(
              values: RangeValues(minRooms.toDouble(), maxRooms.toDouble()),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (RangeValues values) {
                setState(() {
                  minRooms = values.start.toInt();
                  maxRooms = values.end.toInt();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min Price: $minPrice'),
                Text('Max Price: $maxPrice'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min Rooms: $minRooms'),
                Text('Max Rooms: $maxRooms'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: filterHouses,
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  void filterHouses() {
    final housesCollection = FirebaseFirestore.instance.collection('houses');

    Query filteredQuery = housesCollection;

    if (minPrice != 0 || maxPrice != 2000) {
      if (minPrice != 0 && maxPrice != 2000) {
        filteredQuery = filteredQuery.where('price',
            isGreaterThanOrEqualTo: minPrice, isLessThan: maxPrice + 1);
      } else if (minPrice != 0) {
        filteredQuery =
            filteredQuery.where('price', isGreaterThanOrEqualTo: minPrice);
      } else {
        filteredQuery = filteredQuery.where('price', isLessThan: maxPrice + 1);
      }
    }

    filteredQuery.get().then((QuerySnapshot querySnapshot) {
      List<DocumentSnapshot> filteredHouses = querySnapshot.docs;
      // print('Filtered Houses (Price): ${filteredHouses.length}');

      print('Filtered Houses (Rooms): Min $minRooms Max $maxRooms');

      Query roomsQuery = housesCollection;

      // roomsQuery.where('price').get().then((value) =>
      //     print('Filtered Houses (Rooms): = ${value.docs.first.data()}'));

      if (minRooms != 0 || maxRooms != 10) {
        if (minRooms != 0 && maxRooms != 10) {
          roomsQuery = roomsQuery.where('n_rooms',
              isGreaterThanOrEqualTo: minRooms, isLessThanOrEqualTo: maxRooms);
        } else if (minRooms != 0) {
          roomsQuery =
              roomsQuery.where('n_rooms', isGreaterThanOrEqualTo: minRooms);
        } else {
          roomsQuery =
              roomsQuery.where('n_rooms', isLessThanOrEqualTo: maxRooms);
        }
      }
      //else {
      //   print('Final Filtered Houses: Not Woking right');
      // }

      roomsQuery.get().then((QuerySnapshot roomsSnapshot) {
        List<DocumentSnapshot> filteredRooms = roomsSnapshot.docs;
        print('Filtered Houses (Rooms): ${filteredRooms.length}');

        // Combine the results from price and rooms filters
        List<DocumentSnapshot> finalFilteredHouses = [];

        for (var house in filteredHouses) {
          var roomId = house.id;
          var matchingRooms = filteredRooms.where((room) => room.id == roomId);
          if (matchingRooms.isNotEmpty) {
            finalFilteredHouses.add(house);
          }
        }

        print('Final Filtered Houses: ${finalFilteredHouses.length}');

        widget.onFilterApplied(finalFilteredHouses);

        Navigator.pop(context);
      });
    });
  }
}
