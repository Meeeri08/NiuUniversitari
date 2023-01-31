import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../components/tinder_buttons.dart';
import '../components/tinder_candidate_model.dart';
import '../components/tinder_card.dart';
import 'dart:developer';
import 'package:appinio_swiper/appinio_swiper.dart';

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
    _loadCards();
    super.initState();
  }

  void _loadCards() {
    for (TinderCandidateModel candidate in candidates) {
      cards.add(
        TinderCard(
          candidate: candidate,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoPageScaffold(
        backgroundColor: Color.fromARGB(236, 236, 236, 236),
        child: Column(
          children: [
            Container(
              child: const SizedBox(
                height: 50,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.60,
              child: AppinioSwiper(
                unlimitedUnswipe: true,
                controller: controller,
                unswipe: _unswipe,
                cards: cards,
                onSwipe: _swipe,
                padding: const EdgeInsets.only(
                  left: 25,
                  right: 25,
                  top: 20,
                  bottom: 40,
                ),
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
}
