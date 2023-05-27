import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/utils.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController studiesController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final picker = ImagePicker();

  Future<String> uploadImageToFirebase(BuildContext context) async {
    final userId = user.uid;
    final fileName = '$userId.png';
    final destination = 'profile_pictures/$fileName';
    final ref = FirebaseStorage.instance.ref(destination);
    final uploadTask = ref.putData(_image!);
    final snapshot = await uploadTask.whenComplete(() => null);
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<void> _saveProfile() async {
    try {
      final userId = user.uid;
      final profileData = {
        'name': nameController.text,
        'lastName': lastNameController.text,
        'age': ageController.text,
        'studies': studiesController.text,
        'gender': genderController.text,
      };

      if (_image != null) {
        final url = await uploadImageToFirebase(context);
        profileData['imageUrl'] = url;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(profileData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el perfil')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    studiesController.dispose();
    genderController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load user's existing profile data (if available)
    final userId = user.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final profileData = documentSnapshot.data() as Map<String, dynamic>;
        nameController.text = profileData['name'] ?? '';
        lastNameController.text = profileData['lastName'] ?? '';
        ageController.text = profileData['age'] ?? '';
        studiesController.text = profileData['studies'] ?? '';
        genderController.text = profileData['gender'] ?? '';
      }
    });
  }

  Uint8List? _image;

  void selectImage() async {
    final img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(_image!),
                      )
                    : CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(
                          'https://www.pngkit.com/png/detail/72-729913_user-blank-avatar-png.png',
                        ),
                      ),
                Positioned(
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(Icons.add_a_photo),
                  ),
                  bottom: -10,
                  left: 80,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Correo: ${user.email!}'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Edad'),
            ),
            TextField(
              controller: studiesController,
              decoration: const InputDecoration(labelText: 'Estudios'),
            ),
            TextField(
              controller: genderController,
              decoration: const InputDecoration(labelText: 'Sexo'),
            ),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Guardar perfil'),
            ),
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout),
              color: const Color(0xff25262b),
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
      ),
    );
  }
}
