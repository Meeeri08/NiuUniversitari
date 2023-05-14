import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int minPrice = 0;
  int maxPrice = 1000;

  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: TextFormField(
                  controller: minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minimum Price',
                  ),
                ),
              ),
              Flexible(
                child: TextFormField(
                  controller: maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Maximum Price',
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Perform filtering based on the selected values
              filterHouses();
            },
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  void filterHouses() {
    final housesCollection = FirebaseFirestore.instance.collection('houses');

    if (minPriceController.text.isNotEmpty) {
      minPrice = int.parse(minPriceController.text);
    }

    if (maxPriceController.text.isNotEmpty) {
      maxPrice = int.parse(maxPriceController.text);
    }

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
      // Process the filtered houses
      List<DocumentSnapshot> filteredHouses = querySnapshot.docs;
      print('Filtered Houses: ${filteredHouses.length}');

      // Pass the filtered houses back to the HomePage
      Navigator.pop(context, filteredHouses);
    });
  }
}
