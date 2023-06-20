import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jobapp/components/zone_data.dart';

class AddHousePage extends StatefulWidget {
  @override
  _AddHousePageState createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dimensionsController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _petpolicyController = TextEditingController();

  bool isFeatured = false;

  bool isFormValid = false;
  bool isPriceValid = false;
  bool isDepositValid = false;
  bool isTipoSelected = false;
  bool isDateValid = false;

  bool isForm2Valid = false;
  bool isRoomsValid = false;
  bool isBathroomsValid = false;
  bool isDimensionsValid = false;
  bool isPetSelected = false;
  bool isFeatureSelected = false;

  bool isForm3Valid = false;
  bool isTitleValid = false;
  bool isZoneValid = false;
  bool isDescriptionValid = false;
  bool isLocalizationValid = false;
  List<File> _selectedImages = [];
  bool areImagesSelected = false;

  String _selectedAddress = '';

  void _validateForm1() {
    setState(() {
      isFormValid = _priceController.text.isNotEmpty &&
          _depositController.text.isNotEmpty &&
          _initialDate != null &&
          isTipoSelected;
    });
  }

  void _validateForm2() {
    setState(() {
      isRoomsValid = _roomsController.text.isNotEmpty;
      isBathroomsValid = _bathroomsController.text.isNotEmpty;
      isDimensionsValid = _dimensionsController.text.isNotEmpty;
      isFeatureSelected = featuredContainers.contains(true);
      isPetSelected = petPolicy != null;
      isForm2Valid = isRoomsValid &&
          isBathroomsValid &&
          isDimensionsValid &&
          isFeatureSelected &&
          isPetSelected;
    });
  }

  void _validateForm3() {
    setState(() {
      isTitleValid = _titleController.text.isNotEmpty;
      isZoneValid = _zoneController.text.isNotEmpty;
      isDescriptionValid = _descriptionController.text.isNotEmpty;
      isLocalizationValid = _selectedAddress.isNotEmpty;
      areImagesSelected = _selectedImages.isNotEmpty;

      isForm3Valid = isTitleValid &&
          isZoneValid &&
          isDescriptionValid &&
          isLocalizationValid &&
          areImagesSelected;
    });
  }

  void validatePrice(int value) {
    setState(() {
      isPriceValid = value > 0;
    });
  }

  void validateDeposit(int value) {
    setState(() {
      isDepositValid = value > 0;
    });
  }

  void validateDate(DateTime? value) {
    setState(() {
      isDateValid = value != null;
    });
  }

  void validateTipo(String value) {
    setState(() {
      isTipoSelected = value.isNotEmpty;
    });
  }

  void validateFeature(String value) {
    setState(() {
      if (featuredContainers.contains(true)) {
        if (!selectedFeatures.contains(value)) {
          selectedFeatures.add(value);
        }
      } else {
        selectedFeatures.remove(value);
      }
    });
  }

  void validatePet(bool value) {
    setState(() {
      isPetSelected = value;
    });
  }

  void validateRooms(int value) {
    setState(() {
      isRoomsValid = value.toString().isNotEmpty;
    });
  }

  void validateBathrooms(int value) {
    setState(() {
      isBathroomsValid = value.toString().isNotEmpty;
    });
  }

  void validateDimensions(double value) {
    setState(() {
      isDimensionsValid = value.toString().isNotEmpty;
    });
  }

  void goToNextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _addHouseToFirebase();
    }
  }

  List<bool> selectedContainers = [false, false, false, false];
  int selectedContainer = -1;
  void selectContainer(int containerIndex) {
    setState(() {
      selectedContainers = List<bool>.generate(
          selectedContainers.length, (index) => index == containerIndex);
    });
  }

  int minStay = 0;
  int maxStay = 13;
  String zone = '';
  String description = '';
  double dimensions = 0.0;

  List<String> containerNames = [
    'Casa',
    'Habitació',
    'Apartament',
    'Estudi',
  ];

  List<bool> featuredContainers = [false, false, false, false, false];

  void featuredContainer(int containerIndex) {
    setState(() {
      featuredContainers = List<bool>.generate(
          featuredContainers.length, (index) => index == containerIndex);
    });
  }

  List<String> featureNames = [
    'Moblat',
    'Nou',
    'Acabat de Reformar',
    'Servei de Neteja',
    'Parking',
  ];
  @override
  void initState() {
    super.initState();
    selectedContainer = -1;
    _validateForm1();
    _validateForm2();
    _validateForm3();
    _petpolicyController.text = petPolicy ? 'Yes' : 'No';
  }

  bool petPolicy = false;

  List<String> selectedFeatures = [];

  DateTime? _initialDate;
  LatLng? _selectedLocation;

  int _currentStep = 0;
  StepperType _stepperType = StepperType.horizontal;

  Future<String> _getCurrentUserId() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return userId;
  }

  void _selectImages() async {
    final List<XFile>? images =
        await ImagePicker().pickMultiImage(imageQuality: 80);
    if (images != null) {
      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
        _validateForm3();
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    for (File imageFile in _selectedImages) {
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(imageFile);
      String imageUrl = await ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  Future<String> _getCurrentUserName() async {
    String currentUserId = await _getCurrentUserId();
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      String userName = userData['name'] ?? '';
      return userName;
    }

    return '';
  }

  Future<String> _getCurrentUserImageUrl() async {
    String currentUserId = await _getCurrentUserId();
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      String imageUrl = userData['imageUrl'] ?? '';
      return imageUrl;
    }

    return '';
  }

  void _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _initialDate = selectedDate;
      });

      validateDate(_initialDate); // Call validateDate after selecting a date
    }
  }

  void _selectLocation() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapSelectionPage()),
    );

    if (selectedLocation != null) {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        selectedLocation.latitude,
        selectedLocation.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;
        final String address = placemark.street ?? placemark.name ?? '';
        setState(() {
          _selectedLocation = selectedLocation;
          _selectedAddress = address;
          _validateForm3();
        });
      }
    }
  }

  void _addHouseToFirebase() async {
    int numberOfRooms = int.tryParse(_roomsController.text) ?? 0;
    int numberOfBathrooms = int.tryParse(_bathroomsController.text) ?? 0;
    int price = int.tryParse(_priceController.text) ?? 0;
    int deposit = int.tryParse(_depositController.text) ?? 0;
    int minimumStay = minStay;
    int maximumStay = maxStay;
    String zone = _zoneController.text;
    String type = _typeController.text;
    String title = _titleController.text;
    List<String> imageUrls = await _uploadImages();
    bool isFeatured = false;
    String propietari = await _getCurrentUserName();
    String propietariId = await _getCurrentUserId();
    String propietariUrl = await _getCurrentUserImageUrl();

    Map<String, dynamic> houseData = {
      'title': title,
      'image_url': imageUrls.isNotEmpty ? imageUrls[0] : '',
      'imatges': imageUrls.sublist(1),
      'propietari': propietari,
      'featured': isFeatured,
      'propietari_id': propietariId,
      'propietari_url': propietariUrl,
      'barri': zone,
      'datainici':
          _initialDate != null ? Timestamp.fromDate(_initialDate!) : null,
      'n_rooms': numberOfRooms,
      'n_bathroom': numberOfBathrooms,
      'price': price,
      'deposit': deposit,
      'description': description,
      'selected_features': selectedFeatures,
      'minimum_stay': minimumStay,
      'maximum_stay': maximumStay,
      'tipus': type,
      'pet_policy': petPolicy,
      'dimensions': dimensions,
      'latlng': _selectedLocation != null
          ? GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude)
          : null,
    };

    FirebaseFirestore.instance.collection('houses').add(houseData);

    Navigator.pop(context);
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: Text('Etapa 1'),
        content: Column(
          children: [
            Container(
              width: 325,
              child: TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Preu',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      validatePrice(int.parse(value));
                    } else {
                      validatePrice(0);
                    }
                    _validateForm1();
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            SizedBox(height: 32),
            Container(
              width: 325,
              child: TextFormField(
                controller: _depositController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Fiança',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      validatePrice(int.parse(value));
                    } else {
                      validatePrice(0);
                    }
                    _validateForm1();
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            SizedBox(height: 32),
            Container(
              width: 325,
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _initialDate != null
                      ? '${_initialDate!.day}/${_initialDate!.month}/${_initialDate!.year}'
                      : '',
                ),
                decoration: InputDecoration(
                  labelText: 'Disponible a partir de',
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onTap: _selectDate,
                style: TextStyle(
                  color: Colors.black,
                ),
                onChanged: (value) {
                  setState(() {
                    _initialDate = DateTime.parse(value);
                    validateDate(_initialDate);
                    _validateForm1();
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Tipus d\'habitatge',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                      color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: List.generate(4, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedContainer = index;
                      _typeController.text = containerNames[index];
                      validateTipo(containerNames[index]);
                      _validateForm1();
                    });
                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      color: selectedContainer == index
                          ? Colors.teal
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            containerNames[index],
                            style: GoogleFonts.dmSans(
                              color: selectedContainer == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Estada mínima',
                      style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w200,
                          color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    minStay == 0 && maxStay == 13
                        ? 'Sense mínima - 12+ mesos'
                        : minStay == 0
                            ? 'No mínim - $maxStay mesos'
                            : maxStay == 13
                                ? '$minStay - 12+ mesos'
                                : '$minStay - $maxStay mesos',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff25262b),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              subtitle: FlutterSlider(
                handlerHeight: 30,
                handlerWidth: 30,
                values: [minStay.toDouble(), maxStay.toDouble()],
                rangeSlider: true,
                min: 0,
                max: 13,
                step: FlutterSliderStep(step: 1),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    minStay = lowerValue.toInt();
                    maxStay = upperValue.toInt();
                  });
                },
                trackBar: FlutterSliderTrackBar(
                  activeTrackBar: BoxDecoration(color: Color(0xFF1FA29E)),
                  inactiveTrackBar: BoxDecoration(color: Colors.grey.shade300),
                ),
                tooltip: FlutterSliderTooltip(
                  textStyle: TextStyle(fontSize: 0),
                  disabled: true,
                ),
                handler: FlutterSliderHandler(
                  child: Container(),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.teal,
                      width: 2,
                    ),
                  ),
                ),
                rightHandler: FlutterSliderHandler(
                  child: Container(),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.teal,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: 300, // Adjust the width as needed
              height: 60, // Adjust the height as needed
              child: ElevatedButton(
                onPressed: isFormValid ? () => goToNextStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFormValid ? Colors.teal : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Continua'),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
      ),
      Step(
        title: Text('Etapa 2'),
        content: Column(
          children: [
            Container(
              width: 325,
              child: TextFormField(
                controller: _roomsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Nombre d\'habitacions',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      validateRooms(int.parse(value));
                    } else {
                      validateRooms(0);
                    }
                    _validateForm2();
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 325,
              child: TextFormField(
                controller: _bathroomsController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Nombre de banys',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      validateBathrooms(int.parse(value));
                    } else {
                      validateBathrooms(0);
                    }
                    _validateForm2();
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 325,
              child: TextFormField(
                controller: _dimensionsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Dimensions',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      dimensions = double.tryParse(value) ?? 0.0;
                    } else {
                      validateDimensions(0);
                    }
                    _validateForm2();
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Mascotes Permeses',
                      style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w200,
                          color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      petPolicy = true;
                      _petpolicyController.text = 'Sí';
                      validatePet(petPolicy);
                      _validateForm2();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: petPolicy == true
                            ? Colors.teal
                            : Colors.transparent,
                        border: Border.all(
                          color: petPolicy == true ? Colors.teal : Colors.grey,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Sí',
                          style: TextStyle(
                            color:
                                petPolicy == true ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      petPolicy = false;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color:
                          petPolicy == false ? Colors.teal : Colors.transparent,
                      border: Border.all(
                        color: petPolicy == false ? Colors.teal : Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'No',
                        style: TextStyle(
                          color:
                              petPolicy == false ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Característiques',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                      color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: List.generate(4, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      featuredContainers[index] = !featuredContainers[index];
                      validateFeature(featureNames[index]);
                      _validateForm2();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: featuredContainers[index]
                          ? Colors.teal
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Text(
                        featureNames[index],
                        style: GoogleFonts.dmSans(
                          color: featuredContainers[index]
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
            Container(
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: isForm2Valid ? () => goToNextStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isForm2Valid ? Colors.teal : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  //  minimumSize: Size(300, 60),
                ),
                child: Text('Continua'),
              ),
            )
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
      ),
      Step(
        title: Text('Etapa 3'),
        content: Column(
          children: [
            Container(
              width: 325,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _titleController,
                maxLength: 32,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true, // Agregar esta línea
                  fillColor: Colors.white, // Color de fondo blanco
                  labelText: 'Títol de l\'anunci',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  counterText: '',
                ),
                onChanged: (value) {
                  setState(() {
                    _validateForm3();
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 325,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _zoneController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Barri',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    counterText: '',
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return zoneList.where((zone) =>
                      zone.toLowerCase().contains(pattern.toLowerCase()));
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _zoneController.text = suggestion;
                    _validateForm3();
                  });
                },
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 325,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _descriptionController,
                maxLength: 1000,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Descripció',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  counterText: '',
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                    _validateForm3();
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 325,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Ubicació',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onTap: _selectLocation,
                controller: TextEditingController(
                    text: _selectedAddress), // Add this line
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Imatges de la Propietat:',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                      color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        GestureDetector(
                          onTap: _selectImages,
                          child: Container(
                            height: 120,
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: Colors.teal,
                                width: 2.0,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 60,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ),
                        ..._selectedImages.map((image) {
                          return Container(
                            height: 120,
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: FileImage(image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: 300,
              height: 60,
              child: ElevatedButton(
                onPressed: isForm3Valid ? () => goToNextStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isForm3Valid ? Colors.teal : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Continua'),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
      ),
    ];
  }

  void _nextStep() {
    if (_currentStep < _buildSteps().length - 1) {
      setState(() {
        _currentStep++;
        if (_currentStep == _buildSteps().length - 1) {
          _stepperType = StepperType.horizontal;
        }
      });
    } else {
      _addHouseToFirebase();
    }
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Your progress will be lost.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Leave'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (confirm != null && confirm) {
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Publica el teu habitatge',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xff25262b),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 22,
              color: Color(0xff25262b),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('N\'estàs Segur?'),
                      content: Text('Perdràs tot el progrés.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel·la'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Vull sortir'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
        body: Theme(
          data: ThemeData(
            primarySwatch: Colors.teal,
          ),
          child: Stepper(
            controlsBuilder: (context, controller) {
              return const SizedBox.shrink();
            },
            type: _stepperType,
            currentStep: _currentStep,
            onStepContinue: () {
              setState(() {
                if (_currentStep < _buildSteps().length - 1) {
                  _currentStep += 1;
                } else {
                  _addHouseToFirebase();
                }
              });
            },
            steps: _buildSteps(),
          ),
        ),
      ),
    );
  }
}

class MapSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(41.38859447609031, 2.1686747276829004),
              zoom: 14,
            ),
            myLocationButtonEnabled: false,
            onTap: (LatLng location) {
              Navigator.pop(context, location);
            },
          ),
          Positioned(
            top: 28,
            left: 18,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
