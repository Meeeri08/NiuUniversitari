import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobapp/components/tinder_candidate_model.dart';

class TinderCard extends StatelessWidget {
  final TinderCandidateModel candidate;

  const TinderCard({Key? key, required this.candidate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: candidate.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 20),
          Text(candidate.nom ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(candidate.carrera ?? ''),
          Text(candidate.zona ?? ''),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(candidate.image ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              height: 400,
              width: 400,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
