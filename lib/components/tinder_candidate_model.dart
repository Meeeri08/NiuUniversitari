import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TinderCandidateModel {
  String? name;
  String? bio;
  String? image;
  LinearGradient? color;

  TinderCandidateModel({
    this.name,
    this.bio,
    this.image,
    this.color,
  });
}

class TinderScreen extends StatefulWidget {
  @override
  _TinderScreenState createState() => _TinderScreenState();
}

class _TinderScreenState extends State<TinderScreen> {
  List<TinderCandidateModel> candidates = [];

  @override
  void initState() {
    super.initState();
    fetchUsersData().then((data) {
      setState(() {
        candidates = data;
      });
    });
  }

  Future<List<TinderCandidateModel>> fetchUsersData() async {
    List<TinderCandidateModel> candidates = [];

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (DocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic>? userData = doc.data() as Map<String, dynamic>?;
      String? name = userData?['name'];
      String? bio = userData?['bio'];
      String? image = userData?['imageUrl'];

      candidates.add(
        TinderCandidateModel(
          name: name,
          bio: bio,
          image: image,
          color: gradientPink,
        ),
      );
    }

    return candidates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinder'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: candidates.length,
          itemBuilder: (context, index) {
            TinderCandidateModel candidate = candidates[index];

            return Card(
              child: Column(
                children: [
                  Image.network(candidate.image ?? ''),
                  ListTile(
                    title: Text(candidate.name ?? ''),
                    subtitle: Text(candidate.bio ?? ''),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

const LinearGradient gradientRed = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFFF3868),
    Color(0xFFFFB49A),
  ],
);

const LinearGradient gradientPurple = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF736EFE),
    Color(0xFF62E4EC),
  ],
);

const LinearGradient gradientBlue = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF0BA4E0),
    Color(0xFFA9E4BD),
  ],
);

const LinearGradient gradientPink = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFFF6864),
    Color(0xFFFFB92F),
  ],
);

const LinearGradient kNewFeedCardColorsIdentityGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF7960F1),
    Color(0xFFE1A5C9),
  ],
);
