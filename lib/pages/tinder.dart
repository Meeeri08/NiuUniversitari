import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobapp/pages/profile_page.dart';
import 'dart:developer';

import '../components/tinder_buttons.dart';
import '../components/tinder_candidate_model.dart';
import '../components/tinder_card.dart';

class Tinder extends StatefulWidget {
  const Tinder({
    Key? key,
  }) : super(key: key);

  @override
  State<Tinder> createState() => _TinderPageState();
}

class _TinderPageState extends State<Tinder> {
  final AppinioSwiperController controller = AppinioSwiperController();

  List<TinderCard> cards = [];

  @override
  void initState() {
    _checkUserProfile();
    _loadCards();
    super.initState();
  }

  void _loadCards() async {
    String currentUserId = FirebaseAuth
        .instance.currentUser!.uid; // Obtén el ID del usuario actual
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      cards = snapshot.docs
          .where((doc) =>
              doc.id != currentUserId && // Filtrar el propio perfil del usuario
              doc.data() != null && // Verificar si el mapa de datos no es nulo
              (doc.data()! as Map<String, dynamic>)
                  .containsKey('name') && // Verificar si el campo 'name' existe
              (doc.data()! as Map<String, dynamic>)
                  .containsKey('bio') && // Verificar si el campo 'bio' existe
              (doc.data()! as Map<String, dynamic>).containsKey(
                  'imageUrl')) // Verificar si el campo 'imageUrl' existe
          .map((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        return TinderCard(
          candidate: TinderCandidateModel(
            name: data['name'] as String? ?? '',
            bio: data['bio'] as String? ?? '',
            image: data['imageUrl'] as String? ?? '',
            color: gradientPink,
          ),
        );
      }).toList();
    });
  }

  void _checkUserProfile() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;

    if (userData == null ||
        !userData.containsKey('name') ||
        !userData.containsKey('bio') ||
        !userData.containsKey('imageUrl')) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // No se puede cerrar haciendo clic fuera del diálogo ni presionando el botón de retroceso
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Configura tu perfil'),
            content:
                Text('Por favor, configura tu perfil antes de poder acceder.'),
            actions: [
              TextButton(
                child: Text('Configurar perfil'),
                onPressed: () {
                  Navigator.pop(context); // Cerrar el diálogo
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Profile()));
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xfffafafa),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            child: AppinioSwiper(
              swipeOptions: AppinioSwipeOptions.horizontal,
              unlimitedUnswipe: true,
              controller: controller,
              unswipe: _unswipe,
              onSwipe: _swipe,
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
                top: 20,
                bottom: 40,
              ),
              onEnd: _onEnd,
              cardsCount: cards.length,
              cardsBuilder: (BuildContext context, int index) {
                return cards[index];
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 80,
              ),
              swipeLeftButton(controller),
              const SizedBox(
                width: 20,
              ),
              swipeRightButton(controller),
              const SizedBox(
                width: 20,
              ),
              unswipeButton(controller),
            ],
          )
        ],
      ),
    );
  }

  void _swipe(int index, AppinioSwiperDirection direction) {
    log("the card was swiped to the: " + direction.name);
  }

  void _unswipe(bool unswiped) {
    if (unswiped) {
      log("SUCCESS: card was unswiped");
    } else {
      log("FAIL: no card left to unswipe");
    }
  }

  void _onEnd() {
    log("end reached!");
  }
}
