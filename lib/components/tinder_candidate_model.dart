import 'package:flutter/cupertino.dart';

class TinderCandidateModel {
  String? nom;
  String? carrera;
  String? zona;
  String? image; // new field
  LinearGradient? color;

  TinderCandidateModel({
    this.nom,
    this.carrera,
    this.zona,
    this.image, // new field
    this.color,
  });
}

List<TinderCandidateModel> candidates = [
  TinderCandidateModel(
    nom: 'Eight, 8',
    carrera: 'Enginyeria Informàtica',
    zona: 'Sarrià',
    image:
        'https://img.staticmb.com/mbcontent//images/uploads/2022/12/Most-Beautiful-House-in-the-World.jpg',
    color: gradientPink,
  ),
  TinderCandidateModel(
    nom: 'Seven, 7',
    carrera: 'Enginyeria Informàtica',
    zona: 'Sarrià',
    color: gradientBlue,
  ),
  TinderCandidateModel(
    nom: 'Six, 6',
    carrera: 'Enginyeria Informàtica',
    zona: 'Sarrià',
    color: gradientPurple,
  ),
  TinderCandidateModel(
    nom: 'Five, 5',
    carrera: 'Enginyeria Informàtica',
    zona: 'Sarrià',
    color: gradientRed,
  ),
  TinderCandidateModel(
    nom: 'Four, 4',
    carrera: 'Enginyeria Informàtica',
    zona: 'Sarrià',
    color: gradientPink,
  ),
  TinderCandidateModel(
    nom: 'Three, 3',
    carrera: 'Enginyeria Informàtica',
    zona: 'Sarrià',
    color: gradientBlue,
  ),
  TinderCandidateModel(
    nom: 'Two, 2',
    carrera: 'Enginyeria Informàtica',
    zona: 'Sarrià',
    color: gradientPurple,
  ),
  TinderCandidateModel(
    nom: 'One, 1',
    carrera: 'Enginyeria Informàtica',
    zona: 'Sarrià',
    image:
        'https://img.staticmb.com/mbcontent//images/uploads/2022/12/Most-Beautiful-House-in-the-World.jpg',
    color: gradientPink,
  ),
];

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
