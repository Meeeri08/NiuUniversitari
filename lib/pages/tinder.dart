import 'dart:developer';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobapp/pages/filtermatches_page.dart';

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
  List<int>? filteredIndices;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference swipeDataCollection =
      FirebaseFirestore.instance.collection('swipes');
  final CollectionReference matchesCollection =
      FirebaseFirestore.instance.collection('matches');

  List<DocumentSnapshot> userList = [];
  List<Map<String, dynamic>> swipedUsers = [];
  int currentIndex = 0;

  List<TinderCandidateModel> userProfiles = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot>? filteredMatches;

  @override
  void initState() {
    _checkUserProfile();
    loadUsers();
    _updateFilteredIndices();

    super.initState();
  }

  void _updateFilteredIndices() {
    if (filteredMatches != null) {
      filteredIndices =
          filteredMatches!.map<int>((doc) => userList.indexOf(doc)).toList();
    } else {
      filteredIndices = null;
    }
  }

  Future<List<String>> getSwipedUserIds() async {
    List<String> swipedUserIds = [];

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final DocumentSnapshot swipeDocumentSnapshot =
        await swipeDataCollection.doc(currentUserId).get();

    if (swipeDocumentSnapshot.exists) {
      final swipeData = swipeDocumentSnapshot.data();
      if (swipeData != null && swipeData is Map<String, dynamic>) {
        final List<dynamic> profiles = swipeData['profiles'] as List<dynamic>;
        for (final dynamic profile in profiles) {
          if (profile is Map<String, dynamic> &&
              profile.containsKey('profileId')) {
            final String profileId = profile['profileId'] as String;
            swipedUserIds.add(profileId);
          }
        }
      }
    }

    return swipedUserIds;
  }

  Future<void> loadUsers() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    List<String> swipedUserIds = await getSwipedUserIds();

    Query query = usersCollection
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .where('role', isEqualTo: 'Estudiant');

    QuerySnapshot querySnapshot = await query.get();

    setState(() {
      userList = querySnapshot.docs;
    });

    // Filter out already swiped profiles
    userList.removeWhere((user) {
      // Get the user's ID
      String userId = user.id;

      // Check if the user ID exists in the list of swiped user IDs
      bool alreadySwiped = swipedUserIds.contains(userId);

      // If the user has already been swiped, remove them from the user list
      return alreadySwiped;
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

  Future<bool> checkMutualRightSwipe(
      String currentUserID, String swipedUserID) async {
    DocumentSnapshot currentUserSwipedData =
        await swipeDataCollection.doc(currentUserID).get();
    DocumentSnapshot swipedUserSwipedData =
        await swipeDataCollection.doc(swipedUserID).get();

    if (currentUserSwipedData.exists && swipedUserSwipedData.exists) {
      Map<String, dynamic>? currentUserSwipeData =
          currentUserSwipedData.data() as Map<String, dynamic>?;
      Map<String, dynamic>? swipedUserSwipeData =
          swipedUserSwipedData.data() as Map<String, dynamic>?;

      if (currentUserSwipeData != null && swipedUserSwipeData != null) {
        List<Map<String, dynamic>> currentUserProfiles =
            List<Map<String, dynamic>>.from(currentUserSwipeData['profiles']);
        List<Map<String, dynamic>> swipedUserProfiles =
            List<Map<String, dynamic>>.from(swipedUserSwipeData['profiles']);

        bool currentUserRightSwiped = currentUserProfiles.any((data) =>
            data['profileId'] == swipedUserID && data['direction'] == 'right');
        bool swipedUserRightSwiped = swipedUserProfiles.any((data) =>
            data['profileId'] == currentUserID && data['direction'] == 'right');

        return currentUserRightSwiped && swipedUserRightSwiped;
      }
    }

    return false;
  }

  void createMatch(String currentUserID, String swipedUserID) async {
    // Create a new match document
    DocumentReference newMatchDocRef = matchesCollection.doc();

    // Set the match data
    await newMatchDocRef.set({
      'users': [currentUserID, swipedUserID],
      'timestamp': DateTime.now(),
    });

    print('Match created:');
    print('User 1 ID: $currentUserID');
    print('User 2 ID: $swipedUserID');
    print('Timestamp: ${DateTime.now()}');
  }

  void handleSwipe(int index, AppinioSwiperDirection direction) async {
    // Get the current user's document ID
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    if (index >= 0 && index < userList.length) {
      String directionString =
          direction == AppinioSwiperDirection.left ? 'left' : 'right';

      // Get the ID of the swiped user
      String swipedUserId = userList[index].id;

      // Create a document reference for the swipes collection
      DocumentReference swipeDoc = swipeDataCollection.doc(currentUserId);

      // Get the current user's swipe data
      DocumentSnapshot swipeSnapshot = await swipeDoc.get();
      Map<String, dynamic>? swipeData =
          swipeSnapshot.data() as Map<String, dynamic>?;

      // Check if swipeData exists and contains a list of swiped profiles
      if (swipeData != null && swipeData.containsKey('profiles')) {
        List<Map<String, dynamic>> profiles =
            List<Map<String, dynamic>>.from(swipeData['profiles']);

        // Check if the swiped user already exists in the profiles list
        bool existingData = profiles.any((data) =>
            data['profileId'] == swipedUserId &&
            data['direction'] == directionString);

        if (!existingData) {
          // Add the swiped user to the profiles list
          profiles.add({
            'profileId': swipedUserId,
            'direction': directionString,
            'timestamp': DateTime.now(),
          });

          // Update the swipe data in Firestore
          await swipeDoc.set({'profiles': profiles}, SetOptions(merge: true));

          // Check for mutual right swipe
          if (directionString == 'right') {
            bool isMutualRightSwipe =
                await checkMutualRightSwipe(currentUserId, swipedUserId);
            if (isMutualRightSwipe) {
              createMatch(currentUserId, swipedUserId);
            }
          }
        } else {
          print('Swiped user already exists in profiles list.');
          print('Profile ID: $swipedUserId');
          print('Direction: $directionString');
        }
      } else {
        // Create a new document with the initial swipe data
        await swipeDoc.set({
          'profiles': [
            {
              'profileId': swipedUserId,
              'direction': directionString,
              'timestamp': DateTime.now(),
            }
          ]
        });

        print('Swipe data document created:');
        print('Profile ID: $swipedUserId');
        print('Direction: $directionString');
        print('Timestamp: ${DateTime.now()}');
      }

      // Update the current index
      setState(() {
        currentIndex = (currentIndex + 1) % userList.length;
      });
    } else {
      // Reset the current index if it goes out of bounds
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
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 110,
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
                              'profiles':
                                  FieldValue.arrayRemove([lastSwippedData]),
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
                            'direction':
                                directionString.toString().split('.').last,
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
                        cardsCount: filteredIndices != null
                            ? filteredIndices!.length
                            : userList.length,
                        cardsBuilder: (BuildContext context, int index) {
                          final int userListIndex = filteredIndices != null
                              ? filteredIndices![index]
                              : index;
                          return Card(
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Image.network(
                                    userList[userListIndex].get('imageUrl'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 14.0, top: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        userList[userListIndex].get('name'),
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
                                        userList[userListIndex].get('age'),
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
                                      userList[userListIndex].get('degree'),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10),
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: userList[userListIndex]
                                        .get('aficions')
                                        .map<Widget>((aficion) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
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
              ),
            ],
          ),
          // Positioned(
          //   top: 59,
          //   left: 334,
          //   child: IconButton(
          //     icon: const Icon(Icons.search),
          //     color: Colors.grey.shade600,
          //     iconSize: 30,
          //     onPressed: () async {
          //       List<DocumentSnapshot>? result = await Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) {
          //           return FilterMatching(
          //             onFilterApplied: (users) {
          //               setState(() {
          //                 filteredMatches = users;
          //               });
          //             },
          //           );
          //         }),
          //       );
          //       if (result != null) {
          //         setState(() {
          //           filteredMatches = result;
          //         });
          //       }
          //     },
          //   ),
          // ),
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
