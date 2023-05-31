import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
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
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dimensionsController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool petPolicy = false;

  List<File> _selectedImages = [];
  List<DateTime> _selectedDates = [];

  DateTime? _initialDate;
  DateTime? _finalDate;
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

  void _selectDates() async {
    DateTime? initialDate = await showDatePicker(
      context: context,
      initialDate: _initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (initialDate != null) {
      DateTime? finalDate = await showDatePicker(
        context: context,
        initialDate: _finalDate ?? initialDate,
        firstDate: _initialDate ?? initialDate, // Update here
        lastDate: DateTime.now().add(Duration(days: 365)),
      );

      if (finalDate != null) {
        setState(() {
          _initialDate = initialDate;
          _finalDate = finalDate;
        });
      }
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

  void _addHouseToFirebase() async {
    int numberOfRooms = int.tryParse(_roomsController.text) ?? 0;
    int numberOfBathrooms = int.tryParse(_bathroomsController.text) ?? 0;
    int price = int.tryParse(_priceController.text) ?? 0;
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
      'datafinal': _finalDate != null ? Timestamp.fromDate(_finalDate!) : null,
      'n_rooms': numberOfRooms,
      'n_bathroom': numberOfBathrooms,
      'price': price,
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
        title: Text('Step 1'),
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
            const SizedBox(height: 16),
            Text(
              'Main Image:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _selectedImages.isNotEmpty
                ? Container(
                    height: 200,
                    width: 200,
                    child: Image.file(_selectedImages[0]),
                  )
                : Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.add_photo_alternate),
                  ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectImages,
              child: const Text('Select Images'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedImages
                  .skip(1) // Skipping the first image as it's the main picture
                  .map((image) {
                return Container(
                  height: 80,
                  width: 80,
                  child: Image.file(image),
                );
              }).toList(),
            ),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _initialDate != null
                    ? '${_initialDate!.day}/${_initialDate!.month}/${_initialDate!.year}'
                    : '',
              ),
              decoration: const InputDecoration(
                labelText: 'Initial Date',
              ),
              onTap: _selectDates,
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: _finalDate != null
                    ? '${_finalDate!.day}/${_finalDate!.month}/${_finalDate!.year}'
                    : '',
              ),
              decoration: const InputDecoration(
                labelText: 'Final Date',
              ),
              onTap: _selectDates,
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
      ),
      Step(
        title: Text('Step 2'),
        content: Column(
          children: [
            TextFormField(
              controller: _roomsController,
              decoration: const InputDecoration(
                labelText: 'Number of Rooms',
              ),
            ),
            TextFormField(
              controller: _bathroomsController,
              decoration: const InputDecoration(
                labelText: 'Number of Bathrooms',
              ),
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
            ),
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
        title: Text('Step 3'),
        content: Column(
          children: [
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
          // Last step
          _stepperType =
              StepperType.horizontal; // Change stepper type to horizontal
        }
      });
    } else {
      // Last step
      _addHouseToFirebase(); // Call the method to add the house data to Firebase
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
          'Puja la teva vivenda',
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
          // Establecer el color del checkmark en rojo
          primarySwatch: Colors.teal,
        ),
        child: Stepper(
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
