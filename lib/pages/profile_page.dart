import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
        if (imageUrl != null && imageUrl!.isNotEmpty) {
          _loadImage(imageUrl!);
        }
      });
    }
  }

  Future<void> _loadImage(String imageUrl) async {
    if (imageUrl.isNotEmpty && !_isDisposed) {
      setState(() {
        isLoadingImage = true;
      });

      http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200 && !_isDisposed) {
        setState(() {
          profileImageProvider = MemoryImage(response.bodyBytes);
          isLoadingImage = false;
        });
      }
    } else {
      setState(() {
        profileImageProvider = null;
        isLoadingImage = false;
      });
    }
  }

  Uint8List? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
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
      return;
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String name = nameController.text;
    String surname = surnameController.text;
    String bio = bioController.text;

    // Retain the existing email and id values
    userData!['email'] ??= '';
    userData!['id'] ??= '';

    // Guardar los datos en Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({...userData!, 'name': name, 'surname': surname, 'bio': bio});

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          iconSize: 22,
          color: Color(0xff25262b),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                    CircleAvatar(
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
                  decoration: const InputDecoration(
                    hintText: 'Enter Name',
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: surnameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Surname',
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  hintText: 'Enter Bio',
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
