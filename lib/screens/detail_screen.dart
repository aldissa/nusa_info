import 'package:flutter/material.dart';

import '../main.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class DetailScreen extends StatefulWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PostService _postService = PostService();
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    // Future dipanggil di initState, bukan di dalam build()
    _commentsFuture = _postService.fetchComments(widget.post.id);
  }

  void _retry() {
    setState(() {
      _commentsFuture = _postService.fetchComments(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(title: const Text('Baca Warta')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // Badge kategori
          Row(
            children: const [
              Icon(Icons.circle, size: 6, color: NusaInfoApp.terracotta),
              SizedBox(width: 6),
              Text(
                'MUSYAWARAH WARGA',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: NusaInfoApp.terracotta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Judul
          Text(
            _capitalize(post.title),
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 28,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: NusaInfoApp.ink,
            ),
          ),
          const SizedBox(height: 16),

          // Info penulis
          _buildAuthorCard(post),
          const SizedBox(height: 20),

          // Isi pengumuman
          Text(
            _capitalize(post.body.replaceAll('\n', ' ')),
            style: const TextStyle(
              fontSize: 16,
              height: 1.7,
              color: NusaInfoApp.ink,
            ),
          ),
          const SizedBox(height: 24),

          // Pembatas
          Row(
            children: const [
              Expanded(child: Divider(color: NusaInfoApp.hairline)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'KOLOM PARTISIPASI',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: Colors.black45,
                  ),
                ),
              ),
              Expanded(child: Divider(color: NusaInfoApp.hairline)),
            ],
          ),
          const SizedBox(height: 16),

          // Komentar
          FutureBuilder<List<Comment>>(
            future: _commentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildCommentsLoading();
              }

              if (snapshot.hasError) {
                return _buildCommentsError(snapshot.error);
              }

              final comments = snapshot.data ?? [];
              return _buildComments(comments);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCard(Post post) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: NusaInfoApp.terracotta,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'W${post.userId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Warga #${post.userId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: NusaInfoApp.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Warta nomor ${post.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.verified_outlined,
              size: 20,
              color: NusaInfoApp.terracotta,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CircularProgressIndicator(color: NusaInfoApp.terracotta),
      ),
    );
  }

  Widget _buildCommentsError(Object? error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: NusaInfoApp.terracotta,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat tanggapan',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NusaInfoApp.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComments(List<Comment> comments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tanggapan & Saran Warga',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: NusaInfoApp.ink,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EBE3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${comments.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Belum ada tanggapan.',
              style: TextStyle(color: Colors.black54),
            ),
          )
        else
          ...comments.map(
            (comment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CommentCard(comment: comment),
            ),
          ),
      ],
    );
  }
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

class _CommentCard extends StatelessWidget {
  final Comment comment;

  const _CommentCard({required this.comment});

  // Ambil inisial dari email, misal "Eliseo@gardner.biz" -> "EL"
  String get _initials {
    final source = comment.email.isNotEmpty ? comment.email : comment.name;
    final clean = source.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (clean.length < 2) return clean.toUpperCase();
    return clean.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1EBE3),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NusaInfoApp.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(comment.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: NusaInfoApp.ink,
                        ),
                      ),
                      Text(
                        comment.email.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.8,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _capitalize(comment.body.replaceAll('\n', ' ')),
              style: const TextStyle(height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}