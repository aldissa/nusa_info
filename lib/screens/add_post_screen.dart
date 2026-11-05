import 'package:flutter/material.dart';

class AddPostScreen extends StatelessWidget {
  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tulis Maklumat')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Tes kembali dengan sukses'),
        ),
      ),
    );
  }
}