import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobapp/components/zone_data.dart';

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
  int minRooms = 1;
  int maxRooms = 5;
  int minBathrooms = 1;
  int maxBathrooms = 5;
  bool petPolicy = false;

  List<String> selectedBarris = [];

  late String selectedBarriOption;

  late String selectedEstatOption;

  List<String> selectedEstat = [];
  List<String> estatOptions = [
    'Moblat',
    'Nou',
    'Acabat de Reformar',
    'Servei de Neteja',
    'Parking',
  ];

  late String selectedTipusOption;

  List<String> selectedTipus = [];
  List<String> tipusOptions = [
    'Casa',
    'Habitació',
    'Apartament',
    'Estudi',
  ];

  DateTime? _initialDate;

  void _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _initialDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 15),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: const Color(0xff25262b),
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
          const Align(
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
          const SizedBox(height: 20),
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
                        'Preu',
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
                        '\ $minPrice -\ $maxPrice',
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff25262b),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  subtitle: FlutterSlider(
                    handlerHeight: 25,
                    handlerWidth: 25,
                    values: [minPrice.toDouble(), maxPrice.toDouble()],
                    rangeSlider: true,
                    min: 0,
                    max: 2000,
                    step: const FlutterSliderStep(
                        step: 100), // Set the step size to 100
                    onDragging: (handlerIndex, lowerValue, upperValue) {
                      setState(() {
                        minPrice = (lowerValue / 100).round() *
                            100; // Adjust the values in increments of 100
                        maxPrice = (upperValue / 100).round() * 100;
                      });
                    },
                    trackBar: FlutterSliderTrackBar(
                      activeTrackBar:
                          const BoxDecoration(color: Color(0xFF1FA29E)),
                      inactiveTrackBar:
                          BoxDecoration(color: Colors.grey.shade300),
                    ),
                    tooltip: FlutterSliderTooltip(
                      textStyle: const TextStyle(fontSize: 17),
                      custom: (value) {
                        return Text('${value.toInt().toString()}',
                            style: const TextStyle(fontSize: 17));
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
                            offset: const Offset(0, 3),
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
                            offset: const Offset(0, 3),
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
                const SizedBox(height: 20),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Nombre d' "'" 'habitacions',
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
                    '\ $minRooms -\ $maxRooms',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff25262b),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 19),
              child: FlutterSlider(
                handlerHeight: 25,
                handlerWidth: 25,
                values: [minRooms.toDouble(), maxRooms.toDouble()],
                rangeSlider: true,
                min: 1,
                max: 5,
                step: const FlutterSliderStep(step: 1),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    minRooms = (lowerValue / 1).round() * 1;
                    maxRooms = (upperValue / 1).round() * 1;
                  });
                },
                trackBar: FlutterSliderTrackBar(
                  activeTrackBar: const BoxDecoration(color: Color(0xFF1FA29E)),
                  inactiveTrackBar: BoxDecoration(color: Colors.grey.shade300),
                ),
                tooltip: FlutterSliderTooltip(
                  textStyle: const TextStyle(fontSize: 17),
                  custom: (value) {
                    return Text('${value.toInt().toString()}',
                        style: const TextStyle(fontSize: 17));
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
                        offset:
                            const Offset(0, 3), // changes position of shadow
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
                        offset: const Offset(0, 3),
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
          ),

          //Create ListTile for min and max bathrooms
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Nombre de lavabos',
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
                    '\ $minBathrooms -\ $maxBathrooms',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff25262b),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          //create a dropdown button for min and max bathrooms

          ListTile(
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 19),
              child: FlutterSlider(
                handlerHeight: 25,
                handlerWidth: 25,
                values: [minBathrooms.toDouble(), maxBathrooms.toDouble()],
                rangeSlider: true,
                min: 1,
                max: 5,
                step: const FlutterSliderStep(step: 1),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    minBathrooms = (lowerValue / 1).round() * 1;
                    maxBathrooms = (upperValue / 1).round() * 1;
                  });
                },
                trackBar: FlutterSliderTrackBar(
                  activeTrackBar: const BoxDecoration(color: Color(0xFF1FA29E)),
                  inactiveTrackBar: BoxDecoration(color: Colors.grey.shade300),
                ),
                tooltip: FlutterSliderTooltip(
                  textStyle: const TextStyle(fontSize: 17),
                  custom: (value) {
                    return Text('${value.toInt().toString()}',
                        style: const TextStyle(fontSize: 17));
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
                        offset:
                            const Offset(0, 3), // changes position of shadow
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
                        offset:
                            const Offset(0, 3), // changes position of shadow
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
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Permeten mascotes',
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
                  child: Checkbox(
                    value: petPolicy,
                    onChanged: (bool? value) {
                      setState(() {
                        petPolicy = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF1FA29E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Barri',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButtonFormField<String>(
                        value: selectedBarris.isNotEmpty
                            ? selectedBarris[0]
                            : null,
                        items: zoneList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: selectedBarris.contains(value)
                                      ? Colors.blue
                                      : Colors.transparent,
                                ),
                                const SizedBox(width: 10),
                                Center(
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: selectedBarris.contains(value)
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue != null) {
                              if (selectedBarris.contains(newValue)) {
                                selectedBarris.remove(newValue);
                              } else {
                                selectedBarris.add(newValue);
                              }
                            }
                          });
                        },
                        isExpanded: true,
                        hint: const Text('Selecciona'),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Característiques',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: DropdownButtonFormField<String>(
                          value: selectedEstat.isNotEmpty
                              ? selectedEstat[0]
                              : null,
                          items: estatOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: selectedEstat.contains(value)
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    value,
                                    style: TextStyle(
                                      color: selectedEstat.contains(value)
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              if (newValue != null) {
                                if (selectedEstat.contains(newValue)) {
                                  selectedEstat.remove(newValue);
                                } else {
                                  selectedEstat.add(newValue);
                                }
                              }
                            });
                          },
                          isExpanded: true,
                          hint: const Text('Selecciona'),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 15),
            child: SizedBox(
              width: 325,
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _initialDate != null
                      ? '${_initialDate!.day}/${_initialDate!.month}/${_initialDate!.year}'
                      : '',
                ),
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(Icons.calendar_today, color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onTap: _selectDate,
                style: const TextStyle(
                  color: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    _initialDate = DateTime.parse(value);
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Tipus',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 200, // Ancho deseado para el dropdown
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonFormField<String>(
                      value: selectedTipus.isNotEmpty ? selectedTipus[0] : null,
                      items: tipusOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: selectedTipus.contains(value)
                                    ? Colors.blue
                                    : Colors.transparent,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                value,
                                style: TextStyle(
                                  color: selectedTipus.contains(value)
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            if (selectedTipus.contains(newValue)) {
                              selectedTipus.remove(newValue);
                            } else {
                              selectedTipus.add(newValue);
                            }
                          }
                        });
                      },
                      isExpanded: true,
                      hint: const Text('Selecciona'),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ), //Create a button to apply the filters
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50),
            child: Container(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  filterHouses();
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
          const SizedBox(height: 40),
        ]));
  }

  void filterHouses() {
    //house collection in firebase
    final housesCollection = FirebaseFirestore.instance.collection('houses');

    //price Query
    Query priceQuery = housesCollection;

    if (minPrice != 0 || maxPrice != 2000) {
      if (minPrice != 0 && maxPrice != 2000) {
        priceQuery = priceQuery.where('price',
            isGreaterThanOrEqualTo: minPrice, isLessThan: maxPrice + 1);
      } else if (minPrice != 0) {
        priceQuery =
            priceQuery.where('price', isGreaterThanOrEqualTo: minPrice);
      } else {
        priceQuery = priceQuery.where('price', isLessThan: maxPrice + 1);
      }
    }

    //get the houses that match the price filter
    priceQuery.get().then((QuerySnapshot querySnapshot) {
      List<DocumentSnapshot> filteredHouses = querySnapshot.docs;

      print('Filtered Houses (Price): ${filteredHouses.length}');

      //rooms Query
      Query roomsQuery = housesCollection;

      //if the min and max rooms are not the default values
      if (minRooms != 1 || maxRooms != 5) {
        if (minRooms != 1 && maxRooms != 5) {
          roomsQuery = roomsQuery.where('n_rooms',
              isGreaterThanOrEqualTo: minRooms, isLessThanOrEqualTo: maxRooms);
        } else if (minRooms != 1) {
          roomsQuery =
              roomsQuery.where('n_rooms', isGreaterThanOrEqualTo: minRooms);
        } else {
          roomsQuery =
              roomsQuery.where('n_rooms', isLessThanOrEqualTo: maxRooms);
        }
      }

      //get the houses that match the rooms filter
      roomsQuery.get().then((QuerySnapshot roomsSnapshot) {
        List<DocumentSnapshot> filteredRooms = roomsSnapshot.docs;
        print('Filtered Houses (Rooms): ${filteredRooms.length}');

        //bathrooms Query
        Query bathroomQuery = housesCollection;

        //if the min and max rooms are not the default values
        if (minBathrooms != 1 || maxBathrooms != 5) {
          if (minBathrooms != 1 && maxBathrooms != 5) {
            bathroomQuery = bathroomQuery.where('n_bathroom',
                isGreaterThanOrEqualTo: minBathrooms,
                isLessThanOrEqualTo: maxBathrooms);
          } else if (minBathrooms != 1) {
            bathroomQuery = bathroomQuery.where('n_bathroom',
                isGreaterThanOrEqualTo: minBathrooms);
          } else {
            bathroomQuery = bathroomQuery.where('n_bathroom',
                isLessThanOrEqualTo: maxBathrooms);
          }
        }

        //get the houses that match the rooms filter
        bathroomQuery.get().then((QuerySnapshot bathroomSnapshot) {
          List<DocumentSnapshot> filteredBathrooms = bathroomSnapshot.docs;
          print('Filtered Houses (Bathrooms): ${filteredBathrooms.length}');

          //Pets policy Query
          Query petPolicyQuery = housesCollection;

          // Apply pet policy filter if enabled
          if (petPolicy) {
            petPolicyQuery =
                petPolicyQuery.where('pet_policy', isEqualTo: true);
          }

          petPolicyQuery.get().then((QuerySnapshot petPolicySnapshot) {
            List<DocumentSnapshot> filteredPetPolicy = petPolicySnapshot.docs;

            print('Filtered Houses (Pet Policy): ${filteredPetPolicy.length}');

            // barri Query
            Query barriQuery = housesCollection;

            if (selectedBarris.isNotEmpty) {
              barriQuery = barriQuery.where('barri', whereIn: selectedBarris);
            }
            barriQuery.get().then((QuerySnapshot barriSnapshot) {
              List<DocumentSnapshot> filteredBarris = barriSnapshot.docs;
              print('Filtered Houses (Barris): ${filteredBarris.length}');

              // estat Query
              Query estatQuery = housesCollection;

              if (selectedEstat.isNotEmpty) {
                estatQuery = estatQuery.where('estat', whereIn: selectedEstat);
              }
              estatQuery.get().then((QuerySnapshot estatSnapshot) {
                List<DocumentSnapshot> filteredEstat = estatSnapshot.docs;
                print('Filtered Houses (Estat): ${filteredEstat.length}');

                //tipus Query
                Query tipusQuery = housesCollection;

                if (selectedTipus.isNotEmpty) {
                  tipusQuery =
                      tipusQuery.where('tipus', whereIn: selectedTipus);
                }

                tipusQuery.get().then((QuerySnapshot tipusSnapshot) {
                  List<DocumentSnapshot> filteredTipus = tipusSnapshot.docs;
                  print('Filtered Houses (Tipus): ${filteredTipus.length}');

                  //date query
                  Query dateQuery = housesCollection;
                  if (_initialDate != null) {
                    DateTime selectedDate = DateTime(_initialDate!.year,
                        _initialDate!.month, _initialDate!.day);
                    dateQuery = dateQuery.where('datainici',
                        isGreaterThanOrEqualTo:
                            Timestamp.fromDate(selectedDate));
                  }

                  dateQuery.get().then((QuerySnapshot dateSnapshot) {
                    List<DocumentSnapshot> filteredDate = dateSnapshot.docs;
                    print('Filtered Houses (Date): ${filteredDate.length}');

                    List<DocumentSnapshot> finalFilteredHouses = [];

                    for (var house in filteredHouses) {
                      var roomId = house.id;
                      var matchingRooms =
                          filteredRooms.where((room) => room.id == roomId);
                      var matchingBathrooms = filteredBathrooms
                          .where((bathroom) => bathroom.id == roomId);
                      var matchingPetPolicy = filteredPetPolicy
                          .where((petPolicy) => petPolicy.id == roomId);
                      var matchingBarris =
                          filteredBarris.where((barri) => barri.id == roomId);
                      var matchingEstat =
                          filteredEstat.where((estat) => estat.id == roomId);
                      var matchingTipus =
                          filteredTipus.where((tipus) => tipus.id == roomId);
                      var matchingDate = filteredDate
                          .where((_initialDate) => _initialDate.id == roomId);
                      if (matchingRooms.isNotEmpty &&
                          matchingBathrooms.isNotEmpty &&
                          matchingPetPolicy.isNotEmpty &&
                          matchingBarris.isNotEmpty &&
                          matchingEstat.isNotEmpty &&
                          matchingTipus.isNotEmpty &&
                          matchingDate.isNotEmpty) {
                        finalFilteredHouses.add(house);
                      }
                    }

                    print(
                        'Final Filtered Houses: ${finalFilteredHouses.length}');

                    widget.onFilterApplied(finalFilteredHouses);

                    Navigator.pop(context);
                  });
                });
              });
            });
          });
        });
      });
    });
  }
}
