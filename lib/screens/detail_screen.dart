import 'package:flutter/material.dart';

import '../models/post.dart';

class DetailScreen extends StatelessWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baca Warta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(post.title),
      ),
    );
  }
}