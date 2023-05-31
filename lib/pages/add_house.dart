import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddHousePage extends StatefulWidget {
  @override
  _AddHousePageState createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minimumstayController = TextEditingController();
  final TextEditingController _maximumstayController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dimensionsController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();

  bool isPriceValid = false;
  bool isDepositValid = false;
  bool isTipoSelected = false;
  bool isDateValid = false;

  bool isFormValid = false;

  void _validateForm() {
    setState(() {
      isFormValid = _priceController.text.isNotEmpty &&
          _depositController.text.isNotEmpty &&
          _initialDate != null &&
          isTipoSelected;
    });
  }

  void validatePrice(double value) {
    setState(() {
      isPriceValid = value > 0;
    });
  }

  void validateDeposit(double value) {
    setState(() {
      isDepositValid = value > 0;
    });
  }

  void validateDate(DateTime? value) {
    setState(() {
      isDateValid = value != null;
    });

    if (isDateValid) {
      print('Date is validated'); // Add log when date is validated
    }
  }

  void validateTipo(String value) {
    setState(() {
      isTipoSelected = value.isNotEmpty;
    });
  }

  void goToNextStep() {
    setState(() {
      _currentStep++;
    });
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
  int maxStay = 12;

  List<String> containerNames = [
    'Casa',
    'Habitació',
    'Apartament',
    'Estudi',
  ];

  @override
  void initState() {
    super.initState();
    selectedContainer = -1;
    _validateForm();
  }

  bool petPolicy = false;

  List<File> _selectedImages = [];
  List<DateTime> _selectedDates = [];

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
      setState(() {
        _selectedLocation = selectedLocation;
      });
    }
  }

  bool _validateFields() {
    // Validate each field and return false if any field is empty
    if (_titleController.text.isEmpty ||
        _initialDate == null ||
        _selectedImages.isEmpty ||
        _roomsController.text.isEmpty ||
        _bathroomsController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _minimumstayController.text.isEmpty ||
        _maximumstayController.text.isEmpty ||
        _depositController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _dimensionsController.text.isEmpty ||
        _conditionController.text.isEmpty ||
        _zoneController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      return false;
    }
    return true;
  }

  void _addHouseToFirebase() async {
    if (!_validateFields()) {
      final snackBar = SnackBar(
        content: Text('Si us plau, emplena tots els camps'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    int numberOfRooms = int.tryParse(_roomsController.text) ?? 0;
    int numberOfBathrooms = int.tryParse(_bathroomsController.text) ?? 0;
    int price = int.tryParse(_priceController.text) ?? 0;
    int deposit = int.tryParse(_depositController.text) ?? 0;
    int minimumStay = int.tryParse(_minimumstayController.text) ?? 0;
    int maximumStay = int.tryParse(_maximumstayController.text) ?? 0;
    String type = _typeController.text;
    bool petPolicy = false;
    String dimensions = _dimensionsController.text;
    String condition = _conditionController.text;
    String title = _titleController.text;
    List<String> imageUrls = await _uploadImages();
    String propietari = await _getCurrentUserName();
    String propietariId = await _getCurrentUserId();
    String propietariUrl = await _getCurrentUserImageUrl();

    Map<String, dynamic> houseData = {
      'title': title,
      'image_url': imageUrls.isNotEmpty ? imageUrls[0] : '',
      'images': imageUrls
          .sublist(1), // Excluding the first image as it's the main picture
      'propietari': propietari,
      'propietari_id': propietariId,
      'propietari_url': propietariUrl,
      'datainici':
          _initialDate != null ? Timestamp.fromDate(_initialDate!) : null,
      'n_rooms': numberOfRooms,
      'n_bathroom': numberOfBathrooms,
      'price': price,
      'minimum_stay': minimumStay,
      'maximum_stay': maximumStay,
      'tipus': type,
      'pet_policy': petPolicy,
      'dimensions': dimensions,
      'estat': condition,
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
                    validatePrice(double.parse(value));
                    _validateForm();
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
                    validateDeposit(double.parse(value));
                    _validateForm();
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
                    _validateForm();
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
                      validateTipo(containerNames[index]);
                      _validateForm();
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
                    minStay == 0 && maxStay == 12
                        ? 'Sense mínima - 12+ mesos'
                        : minStay == 0
                            ? 'No mínim - $maxStay mesos'
                            : maxStay == 12
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
                max: 12,
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
            ElevatedButton(
              onPressed: isFormValid ? () => goToNextStep() : null,
              style: ElevatedButton.styleFrom(
                primary: isFormValid ? Colors.teal : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Continua'),
            )
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
      ),
      Step(
        title: Text('Etapa 2'),
        content: Column(
          children: [
            TextFormField(
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
                setState(() {});
              },
              style: TextStyle(
                color: Colors.black,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
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
                setState(() {});
              },
              style: TextStyle(
                color: Colors.black,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
              ),
            ),
            DropdownButtonFormField<bool>(
              value: petPolicy,
              decoration: const InputDecoration(
                labelText: 'Pet Policy',
              ),
              items: [
                DropdownMenuItem<bool>(
                  value: true,
                  child: const Text('Yes'),
                ),
                DropdownMenuItem<bool>(
                  value: false,
                  child: const Text('No'),
                ),
              ],
              onChanged: (bool? value) {
                setState(() {
                  petPolicy = value ?? false;
                });
              },
            ),
            TextFormField(
              controller: _dimensionsController,
              decoration: const InputDecoration(
                labelText: 'Dimensions',
              ),
            ),
            TextFormField(
              controller: _conditionController,
              decoration: const InputDecoration(
                labelText: 'Condition',
              ),
            ),
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
                ),
                onChanged: (value) {
                  setState(() {});
                },
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextFormField(
              controller: _zoneController,
              decoration: const InputDecoration(
                labelText: 'Zone',
              ),
            ),
            ElevatedButton(
              onPressed: _selectLocation,
              child: const Text('Select Location'),
            ),
            if (_selectedLocation != null)
              Text(
                  'Selected Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}'),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
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
    return Scaffold(
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
              Navigator.of(context).pop();
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
          onStepCancel: () {
            setState(() {
              if (_currentStep > 0) {
                _currentStep -= 1;
              } else {
                _currentStep = 0;
              }
            });
          },
          steps: _buildSteps(),
        ),
      ),
    );
  }
}

class MapSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(41.38859447609031, 2.1686747276829004),
          zoom: 14,
        ),
        onTap: (LatLng location) {
          Navigator.pop(context, location);
        },
      ),
    );
  }
}
