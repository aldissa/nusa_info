import 'package:flutter/material.dart';

import '../main.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'add_post_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    // Future dipanggil di initState, bukan di dalam build()
    _postsFuture = _postService.fetchPosts();
  }

  // Dipakai tombol "Coba Lagi"
  void _retry() {
    setState(() {
      _postsFuture = _postService.fetchPosts();
    });
  }

  // Dipakai RefreshIndicator (tarik ke bawah)
  Future<void> _refresh() async {
    final newFuture = _postService.fetchPosts();
    setState(() {
      _postsFuture = newFuture;
    });
    try {
      await newFuture;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder, jadi di sini diabaikan
    }
  }

  Future<void> _openAddPost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddPostScreen()),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: NusaInfoApp.ink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Pengumuman berhasil diterbitkan ke warga'),
                ),
              ],
            ),
          ),
        );
    }
  }

  void _openDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warta Terkini')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPost,
        backgroundColor: NusaInfoApp.terracotta,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Tulis'),
      ),
      body: RefreshIndicator(
        color: NusaInfoApp.terracotta,
        onRefresh: _refresh,
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            // 1. Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            // 2. Error + tombol Coba Lagi
            if (snapshot.hasError) {
              return _buildError(snapshot.error);
            }

            // 3. Kosong
            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
              return _buildScrollableMessage(
                icon: Icons.inbox_outlined,
                message: 'Belum ada pengumuman.',
              );
            }

            // 4. Data
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildHeader(posts.length);

                final post = posts[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: index == 1
                      ? _FeaturedCard(post: post, onTap: () => _openDetail(post))
                      : _PostCard(post: post, onTap: () => _openDetail(post)),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.circle, size: 6, color: NusaInfoApp.terracotta),
              SizedBox(width: 6),
              Text(
                'SIARAN RESMI',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: NusaInfoApp.terracotta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Papan Pengumuman Warga',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: NusaInfoApp.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$total WARTA TERKINI',
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 200),
        Center(
          child: CircularProgressIndicator(color: NusaInfoApp.terracotta),
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'MEMPERBARUI WARTA...',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object? error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return _buildScrollableMessage(
      icon: Icons.cloud_off_outlined,
      title: 'Gagal memuat warta',
      message: message,
      showRetry: true,
    );
  }

  // Dibungkus ListView agar RefreshIndicator tetap bisa ditarik
  Widget _buildScrollableMessage({
    required IconData icon,
    String? title,
    required String message,
    bool showRetry = false,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 56, color: NusaInfoApp.terracotta),
        const SizedBox(height: 16),
        if (title != null)
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: NusaInfoApp.ink,
            ),
          ),
        if (title != null) const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, height: 1.4),
        ),
        if (showRetry) ...[
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      ],
    );
  }
}

// Judul JSONPlaceholder huruf kecil semua, rapikan huruf pertamanya
String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

// Kartu utama (pengumuman pertama)
class _FeaturedCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _FeaturedCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE9E1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: NusaInfoApp.terracotta),
                    SizedBox(width: 6),
                    Text(
                      'PENTING',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                        color: NusaInfoApp.terracotta,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _capitalize(post.title),
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: NusaInfoApp.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                post.body.replaceAll('\n', ' '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.5, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              Text(
                'Warga #${post.userId}  •  Warta ${post.id}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NusaInfoApp.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Kartu daftar biasa
class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PENGUMUMAN  •  WARGA #${post.userId}',
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _capitalize(post.title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 19,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: NusaInfoApp.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.body.replaceAll('\n', ' '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.5, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}