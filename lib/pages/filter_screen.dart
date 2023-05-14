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
  int maxPrice = 1000;

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
              max: 1000,
              divisions: 100,
              onChanged: (RangeValues values) {
                setState(() {
                  minPrice = values.start.toInt();
                  maxPrice = values.end.toInt();
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

    if (minPrice != 0 || maxPrice != 1000) {
      if (minPrice != 0 && maxPrice != 1000) {
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
      print('Filtered Houses: ${filteredHouses.length}');

      widget.onFilterApplied(filteredHouses);
      Navigator.pop(context);
    });
  }
}
