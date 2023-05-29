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
  int visibleCardsCount = 3;
  List<TinderCandidateModel> cards = [];
  List<Map<String, dynamic>> swipeDataList = [];
  List<TinderCandidateModel> swipedCards = [];

  @override
  void initState() {
    _checkUserProfile();
    _loadCards();
    super.initState();
  }

  void _loadCards() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<TinderCandidateModel> loadedCards = [];

    for (DocumentSnapshot doc in snapshot.docs) {
      if (doc.id == currentUserId) continue;

      Map<String, dynamic>? userData = doc.data() as Map<String, dynamic>?;

      if (userData != null &&
          userData.containsKey(
              'id') && // Assuming 'id' field exists in the document
          userData.containsKey('name') &&
          userData.containsKey('bio') &&
          userData.containsKey('imageUrl')) {
        String id = userData['id'] as String? ?? '';
        String name = userData['name'] as String? ?? '';
        String bio = userData['bio'] as String? ?? '';
        String imageUrl = userData['imageUrl'] as String? ?? '';

        TinderCandidateModel candidate = TinderCandidateModel(
          id: id,
          name: name,
          bio: bio,
          imageUrl: imageUrl,
        );

        loadedCards.add(candidate);
      }
    }

    setState(() {
      cards = loadedCards;
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
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Configura tu perfil'),
            content: const Text(
                'Por favor, configura tu perfil antes de poder acceder.'),
            actions: [
              TextButton(
                child: const Text('Configurar perfil'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Profile()));
                },
              ),
            ],
          );
        },
      );
    } else {
      // Check if the "swipes" document exists for the current user
      DocumentSnapshot swipeSnapshot = await FirebaseFirestore.instance
          .collection('swipes')
          .doc(currentUserId)
          .get();
      if (!swipeSnapshot.exists) {
        // If the "swipes" document doesn't exist, create it
        await FirebaseFirestore.instance
            .collection('swipes')
            .doc(currentUserId)
            .set({});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xfffafafa),
      child: Column(
        children: [
          const SizedBox(
            height: 150,
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
                final int visibleIndex = index % (visibleCardsCount + 1);
                final bool isSwipedCard = visibleIndex == 0;

                if (isSwipedCard) {
                  return TinderCard(
                    candidate: cards[index],
                  );
                } else {
                  return const SizedBox.shrink();
                }
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
    int swipedIndex = index % cards.length;
    if (swipedIndex >= 0 && swipedIndex < cards.length) {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      String swipedProfileId = cards[swipedIndex].id;
      String swipeDirection = direction.name;

      // Create a Map to represent the swipe data
      Map<String, dynamic> swipeData = {
        'profileId': swipedProfileId,
        'direction': swipeDirection,
        'timestamp': DateTime.now(),
      };

      // Store the swiped profile ID and direction in Firebase
      FirebaseFirestore.instance.collection('swipes').doc(currentUserId).set({
        'swipedProfiles': FieldValue.arrayUnion([swipeData])
      }, SetOptions(merge: true)).then((_) {
        log('Swiped profile stored in Firebase: $swipedProfileId ($swipeDirection)');

        // Add the swipe data to the swipeDataList
        setState(() {
          swipeDataList.add(swipeData);
          visibleCardsCount = cards.length - swipeDataList.length;
        });
      }).catchError((error) {
        log('Failed to store swiped profile in Firebase: $error');
      });

      log('The card was swiped to: $swipeDirection');
    } else {
      log('Invalid index value: $index');
    }
  }

  void _unswipe(bool unswiped) {
    if (unswiped && cards.isNotEmpty && swipeDataList.isNotEmpty) {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Get the most recent swiped profile ID
      Map<String, dynamic> lastSwipeData = swipeDataList.last;
      String swipedProfileId = lastSwipeData['profileId'] as String;

      // Remove the swiped profile record from Firebase
      FirebaseFirestore.instance
          .collection('swipes')
          .doc(currentUserId)
          .update({
        'swipedProfiles': FieldValue.arrayRemove([lastSwipeData])
      }).then((_) {
        log('Swiped profile removed from Firebase: $swipedProfileId');

        // Remove the swiped profile from the swipeDataList
        setState(() {
          swipeDataList.removeLast();
          visibleCardsCount = cards.length - swipeDataList.length;
        });

        // Retrieve the corresponding swiped card from the swipedCards list
        TinderCandidateModel swipedCard = swipedCards.last;

        // Add the unswiped card back to the cards list
        setState(() {
          cards.add(swipedCard);
        });

        log("SUCCESS: Card was unswiped");

        // Remove the swiped card from the swipedCards list
        setState(() {
          swipedCards.removeLast();
        });
      }).catchError((error) {
        log('Failed to remove swiped profile from Firebase: $error');
      });
    } else {
      log("FAIL: No card left to unswipe");
    }
  }

  void _onEnd() {
    log("end reached!");
  }
}
