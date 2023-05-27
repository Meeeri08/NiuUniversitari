import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobapp/utils/add_data.dart';
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
        userData = snapshot.data() as Map<String, dynamic>;
        nameController.text = userData?['name'] ?? '';
        bioController.text = userData?['bio'] ?? '';
        imageUrl = userData?['imageUrl'] ?? '';
        _loadImage(imageUrl!);
      });
    }
  }

  Future<void> _loadImage(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _image = response.bodyBytes;
        });
      }
    }
  }

  Uint8List? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
      imageUrl = null;
    });
  }

  void saveProfile() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String name = nameController.text;
    String bio = bioController.text;

    String resp = await StoreData().saveData(
      userId: userId,
      name: name,
      bio: bio,
      file: _image!,
    );
    print(resp); // Print the response for debugging purposes
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
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 24,
              ),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: Image.memory(
                            _image!,
                            fit: BoxFit.cover,
                          ).image,
                        )
                      : imageUrl != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                              ).image,
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage(
                                  'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                            ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
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
              const SizedBox(
                height: 24,
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  hintText: 'Enter Bio',
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                onPressed: saveProfile,
                child: const Text('Save Profile'),
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
      ),
    );
  }
}
