import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jobapp/pages/profile_page.dart';

import '../components/tinder_buttons.dart';
import '../components/tinder_candidate_model.dart';

class Tinder extends StatefulWidget {
  const Tinder({
    Key? key,
  }) : super(key: key);

  @override
  State<Tinder> createState() => _TinderPageState();
}

class _TinderPageState extends State<Tinder> {
  final AppinioSwiperController controller = AppinioSwiperController();
  //testing

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference swipeDataCollection =
      FirebaseFirestore.instance.collection('swipes');
  List<DocumentSnapshot> userList = [];
  List<Map<String, dynamic>> swipedUsers = [];
  int currentIndex = 0;

  List<TinderCandidateModel> userProfiles = [];

  @override
  void initState() {
    _checkUserProfile();
    loadUsers();
    super.initState();
  }

  // testing

  Future<void> loadUsers() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await usersCollection
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .get();

    setState(() {
      userList = querySnapshot.docs;
    });
  }

  void handleSwipeRight() async {
    DocumentSnapshot currentUser = userList[currentIndex];
    String direction = await usersCollection
        .doc(currentUser.id)
        .get()
        .then((docSnapshot) => docSnapshot.get('direction'));

    if (direction == 'left') {
      // Update direction to 'right' if previously swiped left
      await usersCollection.doc(currentUser.id).update({
        'direction': 'right',
      });
    } else {
      // Display message that no users have been swiped left
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Users Swiped Left'),
            content: Text('No users have been swiped left before.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    setState(() {
      currentIndex = (currentIndex + 1) % userList.length;
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
        !userData.containsKey('degree') ||
        !userData.containsKey('age') ||
        !userData.containsKey('aficions') ||
        !userData.containsKey('imageUrl')) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Configura el teu perfil'),
            content: const Text(
                'Si us plau, configureu el vostre perfil abans de poder accedir-hi.'),
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
    } else {}
  }

  void handleSwipe(int index, AppinioSwiperDirection direction) async {
    DocumentSnapshot currentUser = userList[index];
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String profileId = currentUser.id;

    if (index >= 0 && index < userList.length) {
      String directionString =
          direction == AppinioSwiperDirection.left ? 'left' : 'right';

      // Get the current user's document
      DocumentReference userDoc = swipeDataCollection.doc(profileId);

      // Get the current user's swipe data map
      DocumentSnapshot userSnapshot = await userDoc.get();

      // Check if the "swipeData" field exists in the document
      if (userSnapshot.exists &&
          (userSnapshot.data() as Map).containsKey("swipeData")) {
        List<Map<String, dynamic>>? swipeData =
            List<Map<String, dynamic>>.from(userSnapshot.get("swipeData"));

        // Check if the swipe data already exists for the current user
        bool existingData = swipeData.any((data) =>
            data['profileId'] == profileId &&
            data['direction'] == directionString);
        // Create a new swipe data list if it doesn't exist
        swipeData ??= [];
        if (!existingData) {
          // Swipe data already exists, update the existing entry
          swipeData.add({
            'profileId': profileId,
            'direction': directionString,
            'timestamp': DateTime.now(),
          });
        }
        // Add the new swipe data entry to the list

        // Update the current user's document with the updated swipe data list
        await userDoc.update({'swipeData': swipeData});
      } else {
        // Create a new document with the initial swipe data entry
        await userDoc.set({
          'swipeData': [
            {
              'profileId': profileId,
              'direction': directionString,
              'timestamp': Timestamp.now(),
            }
          ]
        });
      }

      setState(() {
        currentIndex = (currentIndex + 1) % userList.length;
      });
    } else {
      setState(() {
        currentIndex = 0;
      });
    }
  }

  Future<void> handleOnEnd() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Swiping ended'),
          content: const Text('You have finished swiping all cards.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void handleUnSwap(bool isSwipedLeft) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDoc = swipeDataCollection.doc();

    // Get the current user's document snapshot
    DocumentSnapshot userSnapshot = await userDoc.get();

    // Check if the "swipeData" field exists in the document
    if (userSnapshot.exists &&
        (userSnapshot.data() as Map).containsKey("swipeData")) {
      List<Map<String, dynamic>> swipeData =
          List<Map<String, dynamic>>.from(userSnapshot.get("swipeData"));

      if (swipeData.isNotEmpty) {
        // Remove the last entry from the swipe data list
        swipeData.removeLast();

        // Update the current user's document with the updated swipe data list
        await userDoc.update({'swipeData': swipeData});
      }
    }

    setState(() {
      currentIndex = (currentIndex - 1) % userList.length;
    });
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
          userList.length == 0
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.60,
                  child: AppinioSwiper(
                    swipeOptions: AppinioSwipeOptions.horizontal,
                    unlimitedUnswipe: true,
                    controller: controller,
                    unswipe: (bool isSwiped) async {
                      if (isSwiped) {
                        if (currentIndex <= 0) {
                          return;
                        }
                        final Map<String, dynamic> lastSwippedData =
                            swipedUsers.last;
                        await swipeDataCollection
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .set({
                          'profiles': FieldValue.arrayRemove([lastSwippedData]),
                        }, SetOptions(merge: true));
                        swipedUsers.removeLast();
                        setState(() {
                          currentIndex--;
                        });
                      } else {
                        print('Error');
                      }
                    },
                    onSwipe: (i, direction) async {
                      if (currentIndex >= userList.length) {
                        return;
                      }
                      String directionString =
                          direction == AppinioSwiperDirection.left
                              ? 'left'
                              : 'right';
                      final swappedData = {
                        'profileId': userList[currentIndex]['id'],
                        'direction': directionString.toString().split('.').last,
                        'timestamp': DateTime.now()
                      };
                      swipedUsers.add(swappedData);

                      await swipeDataCollection
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .set({
                        'profiles': FieldValue.arrayUnion(
                          [swappedData],
                        ),
                      }, SetOptions(merge: true));
                      setState(() {
                        currentIndex++;
                      });
                    },
                    padding: const EdgeInsets.only(
                      left: 25,
                      right: 25,
                      top: 20,
                      bottom: 40,
                    ),
                    onEnd: handleOnEnd,
                    cardsCount: userList.length - 1,
                    cardsBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 4 / 3,
                              child: Image.network(
                                userList[index].get('imageUrl'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 14.0, top: 10),
                              child: Row(
                                children: [
                                  Text(
                                    userList[index].get('name'),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                  Text(
                                    ', ',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                  Text(
                                    userList[index].get('age'),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  userList[index].get('degree'),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, right: 10),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: userList[index]
                                    .get('aficions')
                                    .map<Widget>((aficion) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.teal.withOpacity(0.2),
                                    ),
                                    child: Text(
                                      aficion,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w200,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
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

  handleSwip(direction) {
    if (currentIndex >= 0 && currentIndex < userList.length) {
      try {
        print(userList[currentIndex]['id']);
        print(userList[currentIndex]['name']);
        final currentUser = FirebaseAuth.instance.currentUser;

        String cardDirection =
            direction == AppinioSwiperDirection.left ? 'left' : 'right';
        final swipesCollection =
            FirebaseFirestore.instance.collection('swipes');
        // Create a document for the current user's UID
        final currentUserSwipesDoc =
            swipesCollection.doc(FirebaseAuth.instance.currentUser!.uid);
        // Create a map of the swiped card data
        final swipedCardData = {
          'profileId': userList[currentIndex]['id'],
          'direction': cardDirection,
          'timestamp': DateTime.now(),
        };
        // Add the swiped card data to the "swipes" collection document
        final added = currentUserSwipesDoc.set(
            {
              'data': FieldValue.arrayUnion([swipedCardData])
            },
            SetOptions(
              merge: true,
            ));

        currentIndex++;
      } on FirebaseFirestore catch (e) {
        controller.unswipe();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while swaping.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );

        print('An error occurred while handling the swipe: $e');
      } catch (e) {
        controller.unswipe();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while swaping.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );

        print('An error occurred while handling the swipe: $e');
      }
    } else {
      currentIndex++;
    }
  }

  void _unswipe(bool unswiped) async {
    DocumentSnapshot currentUser = userList[currentIndex];
    await usersCollection.doc(currentUser.id).update({
      'direction': 'left',
    });
    setState(() {
      currentIndex = (currentIndex + 1) % userList.length;
    });
  }

  void _onEnd() {
    log("end reached!");
  }
}
