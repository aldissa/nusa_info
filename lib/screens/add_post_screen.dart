import 'package:flutter/material.dart';

import '../main.dart';
import '../services/post_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final PostService _postService = PostService();

  // Kunci untuk memvalidasi form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Jalankan semua validator, berhenti kalau ada yang tidak valid
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _postService.createPost(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );

      if (!mounted) return;
      // Kembali ke Home membawa hasil sukses
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: NusaInfoApp.terracotta,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tulis Maklumat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LEMBAR MAKLUMAT WARGA',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Judul
              const _FieldLabel(number: '1', text: 'JUDUL PENGUMUMAN'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                enabled: !_isSubmitting,
                maxLength: 100,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'cth. Kerja Bakti Saluran Air RW 04',
                  helperText:
                      'Maksimal 100 karakter yang jelas dan ringkas.',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Judul tidak boleh kosong';
                  if (text.length < 10) {
                    return 'Judul minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. Isi
              const _FieldLabel(number: '2', text: 'ISI PENGUMUMAN'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bodyController,
                enabled: !_isSubmitting,
                maxLength: 1200,
                minLines: 6,
                maxLines: 10,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText:
                      'Tuliskan rincian informasi, waktu pelaksanaan, titik kumpul atau lokasi, serta narahubung.',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Isi pengumuman tidak boleh kosong';
                  if (text.length < 30) {
                    return 'Isi minimal 30 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tombol kirim
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _isSubmitting ? 'Mengirim...' : 'Kirim Pengumuman',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String number;
  final String text;

  const _FieldLabel({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$number. $text',
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
      ),
    );
  }
}