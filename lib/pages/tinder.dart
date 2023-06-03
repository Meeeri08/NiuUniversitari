import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
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
      // DocumentSnapshot swipeSnapshot = await FirebaseFirestore.instance
      //     .collection('swipes')
      //     .doc(currentUserId)
      //     .get();
      // if (!swipeSnapshot.exists) {
      //   // If the "swipes" document doesn't exist, create it
      //   await FirebaseFirestore.instance
      //       .collection('swipes')
      //       .doc(currentUserId)
      //       .set({});
      // }
    }
  }

  void handleSwipe(int index, AppinioSwiperDirection direction) async {
    DocumentSnapshot currentUser = userList[index];
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String profileId = currentUser.id;

    if (index >= 0 && index < userList.length) {
      String directionString =
          direction == AppinioSwiperDirection.left ? 'left' : 'right';

      // Print debug information
      print('UserList length: ${userList.length}');
      print('Current index: $index');
      print('Current user ID: $currentUserId');
      print('Direction: $directionString');
      print('Profile ID: $profileId');

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
    // final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // DocumentReference userDoc = swipeDataCollection.doc(currentUserId);

    // // Clear all swipe data for the current user
    // await userDoc.update({'swipeData': []});

    // setState(() {
    //   currentIndex = 0;
    // });
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
          userList.isEmpty
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
                      //final int visibleIndex = index % (visibleCardsCount + 1);
                      // final bool isSwipedCard = visibleIndex == 0;

                      return Card(
                        child: Column(
                          children: [
                            // if (index >= 0 && index < userList.length)
                            AspectRatio(
                              aspectRatio: 4 / 3,
                              child: Image.network(
                                userList[index].get('imageUrl'),
                              ),
                            ),

                            // if (index >= 0 && index < userList.length)
                            Text(
                              userList[index].get('name'),
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

  // void _swipe(int index, AppinioSwiperDirection direction) {
  //   int swipedIndex = index % cards.length;
  //   if (swipedIndex >= 0 && swipedIndex < cards.length) {
  //     String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //     String swipedProfileId = cards[swipedIndex].id;
  //     String swipeDirection = direction.name;

  //     // Create a Map to represent the swipe data
  //     Map<String, dynamic> swipeData = {
  //       'profileId': swipedProfileId,
  //       'direction': swipeDirection,
  //       'timestamp': DateTime.now(),
  //     };

  //     // Store the swiped profile ID and direction in Firebase
  //     FirebaseFirestore.instance.collection('swipes').doc(currentUserId).set({
  //       'swipedProfiles': FieldValue.arrayUnion([swipeData])
  //     }, SetOptions(merge: true)).then((_) {
  //       log('Swiped profile stored in Firebase: $swipedProfileId ($swipeDirection)');

  //       // Add the swipe data to the swipeDataList
  //       setState(() {
  //         swipeDataList.add(swipeData);
  //         visibleCardsCount = cards.length - swipeDataList.length;
  //       });
  //     }).catchError((error) {
  //       log('Failed to store swiped profile in Firebase: $error');
  //     });

  //     log('The card was swiped to: $swipeDirection');
  //   } else {
  //     log('Invalid index value: $index');
  //   }
  // }

  void _unswipe(bool unswiped) async {
    // if (unswiped && cards.isNotEmpty && swipeDataList.isNotEmpty) {
    //   String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    //   // Get the most recent swiped profile ID
    //   Map<String, dynamic> lastSwipeData = swipeDataList.last;
    //   String swipedProfileId = lastSwipeData['profileId'] as String;

    //   // Remove the swiped profile record from Firebase
    //   FirebaseFirestore.instance
    //       .collection('swipes')
    //       .doc(currentUserId)
    //       .update({
    //     'swipedProfiles': FieldValue.arrayRemove([lastSwipeData])
    //   }).then((_) {
    //     log('Swiped profile removed from Firebase: $swipedProfileId');

    //     // Remove the swiped profile from the swipeDataList
    //     setState(() {
    //       swipeDataList.removeLast();
    //       visibleCardsCount = cards.length - swipeDataList.length;
    //     });

    //     // Retrieve the corresponding swiped card from the swipedCards list
    //     TinderCandidateModel swipedCard = swipedCards.last;

    //     // Add the unswiped card back to the cards list
    //     setState(() {
    //       cards.add(swipedCard);
    //     });

    //     log("SUCCESS: Card was unswiped");

    //     // Remove the swiped card from the swipedCards list
    //     setState(() {
    //       swipedCards.removeLast();
    //     });
    //   }).catchError((error) {
    //     log('Failed to remove swiped profile from Firebase: $error');
    //   });
    // } else {
    //   log("FAIL: No card left to unswipe");
    // }
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
