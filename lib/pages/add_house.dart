import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHousePage extends StatefulWidget {
  @override
  _AddHousePageState createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> {
  final TextEditingController _titleController = TextEditingController();
  List<File> _selectedImages = [];

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

  void _addHouseToFirebase() async {
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
    };

    FirebaseFirestore.instance.collection('houses').add(houseData);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add House'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Imatge Principal:',
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
              child: const Text('Selecciona les imatges'),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addHouseToFirebase,
              child: const Text('Add House'),
            ),
          ],
        ),
      ),
    );
  }
}
