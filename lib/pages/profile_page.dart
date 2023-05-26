import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> _saveProfile() async {
    final profileData = {
      'name': nameController.text,
      'lastName': lastNameController.text,
      'age': ageController.text,
      'studies': studiesController.text,
      'gender': genderController.text,
    };

    try {
      final userId = user.uid;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      body: Column(
        children: [
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
    );
  }
}
