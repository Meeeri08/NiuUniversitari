import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jobapp/pages/home_page.dart';

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
        bioController.text = userData?['bio'] ?? '';
        imageUrl = userData?['imageUrl'] ?? '';
        selectedRole = userData?['role'] ?? '';

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
  final TextEditingController bioController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

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
    String bio = bioController.text;
    String role = selectedRole ?? '';

    // Retain the existing email and id values
    userData!['email'] ??= '';
    userData!['id'] ??= '';

    // Guardar los datos en Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      ...userData!,
      'name': name,
      'surname': surname,
      'bio': bio,
      'role': role
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
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
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
              GestureDetector(
                onTap: () {
                  // Navegar a la pantalla de edición y pasar los datos del campo
                },
                child: TextField(
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
                  hintText: 'Enter Surname',
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
                controller: bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter Bio',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                ),
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              const Text(
                'Choose your role',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    saveProfile();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                },
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
