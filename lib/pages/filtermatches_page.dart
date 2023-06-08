import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterMatching extends StatefulWidget {
  final Function(List<DocumentSnapshot>?) onFilterApplied;

  const FilterMatching({Key? key, required this.onFilterApplied})
      : super(key: key);

  @override
  _FilterMatchingState createState() => _FilterMatchingState();
}

class _FilterMatchingState extends State<FilterMatching> {
  int minAge = 16;
  int maxAge = 99;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 15),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Color(0xff25262b),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text('Filtrar',
                style: GoogleFonts.dmSans(
                  color: const Color(0xff25262b),
                  fontWeight: FontWeight.w500,
                )),
          ),
          backgroundColor: Colors.white,
        ),
        body: ListView(shrinkWrap: true, children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 30, top: 30),
              child: Text(
                'Preferències',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'dmSans',
                  fontSize: 24,
                  color: Color(0xff25262b),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'Edat',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        '\ $minAge -\ $maxAge',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff25262b),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ListTile(
                  subtitle: FlutterSlider(
                    handlerHeight: 25,
                    handlerWidth: 25,
                    values: [minAge.toDouble(), maxAge.toDouble()],
                    rangeSlider: true,
                    min: 16,
                    max: 99,
                    step: FlutterSliderStep(step: 1),
                    onDragging: (handlerIndex, lowerValue, upperValue) {
                      setState(() {
                        minAge = lowerValue.toInt();
                        maxAge = upperValue.toInt();
                      });
                    },
                    trackBar: FlutterSliderTrackBar(
                      activeTrackBar: BoxDecoration(color: Color(0xFF1FA29E)),
                      inactiveTrackBar:
                          BoxDecoration(color: Colors.grey.shade300),
                    ),
                    tooltip: FlutterSliderTooltip(
                      textStyle: TextStyle(fontSize: 17),
                      custom: (value) {
                        return Text('${value.toInt().toString()}',
                            style: TextStyle(fontSize: 17));
                      },
                    ),
                    handler: FlutterSliderHandler(
                      child: Container(),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                    rightHandler: FlutterSliderHandler(
                      child: Container(),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),

          SizedBox(
            height: 50,
          ), //Create a button to apply the filters
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50),
            child: Container(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  filterMatches();
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
                  "Aplica els filtres",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
        ]));
  }

  void filterMatches() {
    final usersCollection = FirebaseFirestore.instance.collection('users');

    Query ageQuery = usersCollection
        .where('age', isGreaterThanOrEqualTo: minAge.toString())
        .where('age', isLessThanOrEqualTo: maxAge.toString());

    ageQuery.get().then((QuerySnapshot querySnapshot) {
      List<DocumentSnapshot> filteredMatches = querySnapshot.docs;

      print('Filtered Matches (age): ${filteredMatches.length}');

      List<DocumentSnapshot> finalFilteredMatches = [];

      for (var filteredUser in filteredMatches) {
        finalFilteredMatches.add(filteredUser);
      }

      print('Final Filtered Matches: ${finalFilteredMatches.length}');

      widget.onFilterApplied(finalFilteredMatches);

      Navigator.pop(context);
    });
  }
}
