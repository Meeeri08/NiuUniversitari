import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jobapp/components/tinder_candidate_model.dart';

class TinderCard extends StatelessWidget {
  final TinderCandidateModel candidate;

  const TinderCard({
    required this.candidate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.network(
            candidate.imageUrl ?? '',
          ),
          ListTile(
            title: Text(candidate.name ?? ''),
            subtitle: Text(candidate.bio ?? ''),
          ),
        ],
      ),
    );
  }
}
