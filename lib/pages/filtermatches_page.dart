import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FilterMatching extends StatefulWidget {
  const FilterMatching({Key? key}) : super(key: key);

  @override
  _FilterMatchingState createState() => _FilterMatchingState();
}

class _FilterMatchingState extends State<FilterMatching> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter'),
      ),
      body: Center(
        child: Text('Filter'),
      ),
    );
  }
}
