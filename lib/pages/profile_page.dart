import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jobapp/pages/home_page.dart';
import 'package:jobapp/components/carreres.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../components/aficions.dart';
import '../utils/utils.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  String? imageUrl;
  bool isLoadingImage = false;
  ImageProvider? profileImageProvider;
  bool _isDisposed = false;
  String? selectedRole;
  String? selectedDegree;
  List<MultiSelectItem<String>> _items = aficionsList
      .map((aficion) => MultiSelectItem<String>(aficion, aficion))
      .toList();

  late List<bool> _itemCheckedList;
  final ValueNotifier<List<String>> _selectedAficions =
      ValueNotifier<List<String>>([]);

  @override
  void dispose() {
    print('dispose() called');
    _isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('initState() called');
    _itemCheckedList = List.generate(_items.length, (index) => false);
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      setState(() {
        userData = snapshot.data() as Map<String, dynamic>?;
        // Retain the existing email and id values
        userData!['email'] ??= '';
        userData!['id'] ??= '';
        nameController.text = userData?['name'] ?? '';
        surnameController.text = userData?['surname'] ?? '';
        imageUrl = userData?['imageUrl'] ?? '';
        selectedRole = userData?['role'] ?? '';
        degreeController.text = userData?['degree'] ?? '';
        ageController.text = userData?['age'] ?? '';

        List<dynamic> aficions = userData?['aficions'] ?? [];
        _selectedAficions.value =
            aficions.map((aficion) => aficion.toString()).toList();

        if (imageUrl != null && imageUrl!.isNotEmpty) {
          _loadImage(imageUrl!);
        }
      });
    }
  }

  Future<void> _loadImage(String imageUrl) async {
    if (imageUrl.isNotEmpty && !_isDisposed && mounted) {
      setState(() {
        isLoadingImage = true;
      });

      http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200 && !_isDisposed && mounted) {
        setState(() {
          profileImageProvider = MemoryImage(response.bodyBytes);
          isLoadingImage = false;
        });
      }
    } else {
      if (!_isDisposed && mounted) {
        setState(() {
          profileImageProvider = null;
          isLoadingImage = false;
        });
      }
    }
  }

  Uint8List? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null && !_isDisposed) {
      setState(() {
        _image = img;
        profileImageProvider = MemoryImage(_image!);
        imageUrl = null;
      });
    }
  }

  Future<void> saveProfile() async {
    if (_isDisposed) {
      print('Attempted to save profile after dispose');
      return;
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String name = nameController.text;
    String surname = surnameController.text;
    String role = selectedRole ?? '';
    String degree = degreeController.text;
    String age = ageController.text;
    _selectedAficions.value;

    // Retain the existing email and id values
    userData!['email'] ??= '';
    userData!['id'] ??= '';

    // Guardar los datos en Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      ...userData!,
      'name': name,
      'surname': surname,
      'role': role,
      'degree': degree,
      'age': age,
      'aficions': _selectedAficions.value,
    });

    // Guardar la imagen en Firebase Storage
    if (_image != null) {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('$userId.jpg');

      // Subir la imagen al storage
      UploadTask uploadTask = storageRef.putData(_image!);

      // Obtener la URL de descarga de la imagen
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Guardar la URL de la imagen en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'imageUrl': downloadUrl});
    }

    print('Perfil guardado correctamente');
  }

  @override
  Widget build(BuildContext context) {
    print('build() called');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Perfil',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xff25262b),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Stack(
                children: [
                  if (profileImageProvider != null)
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 64,
                      backgroundImage: profileImageProvider,
                    )
                  else
                    const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 64,
                      backgroundImage: AssetImage('assets/default.png'),
                    ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Nom',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.all(10),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: surnameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Cognom',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Edat',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.all(10),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  counterText: '', // Hide character count
                ),
                style: TextStyle(
                  color: Colors.black,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 2,
              ),
              const SizedBox(height: 24),
              const Text(
                'Escull el teu Rol',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = 'Estudiant';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedRole == 'Estudiant'
                            ? Colors.teal
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Text(
                          'Estudiant',
                          style: TextStyle(
                            color: selectedRole == 'Estudiant'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = 'Propietari';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedRole == 'Propietari'
                            ? Colors.teal
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Text(
                          'Propietari',
                          style: TextStyle(
                            color: selectedRole == 'Propietari'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                  visible: selectedRole == 'Estudiant',
                  child: const SizedBox(height: 24)),
              Visibility(
                visible: selectedRole == 'Estudiant',
                child: Container(
                  width: 325,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: degreeController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Grau',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      counterText: '',
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (degreeList.contains(value)) {
                          selectedDegree = value;
                        } else {
                          selectedDegree = null;
                        }
                      });
                    },
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Escull el teu Grau',
                                style: GoogleFonts.dmSans()),
                            content: Container(
                              width: double.maxFinite,
                              child: ListView.builder(
                                itemCount: degreeList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final degree = degreeList[index];
                                  return ListTile(
                                    title: Text(degree),
                                    onTap: () {
                                      setState(() {
                                        degreeController.text = degree;
                                        selectedDegree = degree;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    readOnly: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Visibility(
                visible: selectedRole == 'Estudiant',
                child: Container(
                  child: Column(
                    children: [
                      MultiSelectDialogField(
                        items: _items,
                        title: Text("Aficions"),
                        initialValue: _selectedAficions.value, // Add this line

                        selectedColor: Colors.teal,
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          border: Border.all(
                            color: Colors.teal,
                            width: 2,
                          ),
                        ),
                        buttonIcon: Icon(
                          Icons.brush_outlined,
                          color: Colors.teal,
                        ),
                        buttonText: Text(
                          "Aficions",
                          style: TextStyle(
                            color: Colors.teal[800],
                            fontSize: 16,
                          ),
                        ),
                        onConfirm: (results) {
                          setState(() {
                            _selectedAficions.value = results.cast<String>();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    saveProfile();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                },
                child: Container(
                  width: 300,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.teal,
                  ),
                  child: Center(
                    child: Text(
                      'Desar Perfil',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
