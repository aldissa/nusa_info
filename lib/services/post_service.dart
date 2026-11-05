import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/post.dart';

class PostService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // GET /posts
  Future<List<Post>> fetchPosts() async {
    // 1. Buat alamat
    final url = Uri.parse('$_baseUrl/posts');

    // 2. Kirim request
    final response = await _send(() => http.get(url));

    // 3. Cek status code
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat pengumuman (${response.statusCode})');
    }

    // 4. Ubah JSON menjadi objek
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Post.fromJson(item)).toList();
  }

  // GET /posts/{id}/comments
  Future<List<Comment>> fetchComments(int postId) async {
    final url = Uri.parse('$_baseUrl/posts/$postId/comments');

    final response = await _send(() => http.get(url));

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat komentar (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Comment.fromJson(item)).toList();
  }

  // POST /posts
  Future<Post> createPost({
    required String title,
    required String body,
  }) async {
    final url = Uri.parse('$_baseUrl/posts');

    final response = await _send(
      () => http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
      ),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal mengirim pengumuman (${response.statusCode})');
    }

    return Post.fromJson(jsonDecode(response.body));
  }

  // Membungkus request supaya error internet mati jadi pesan yang ramah.
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(const Duration(seconds: 10));
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on http.ClientException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Koneksi terlalu lama. Silakan coba lagi.');
      }
      rethrow;
    }
  }
}

// Model komentar untuk Detail Screen
class Comment {
  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['postId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}