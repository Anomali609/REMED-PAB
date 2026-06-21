import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/article_model.dart';
import '../services/firestore_service.dart';

class DetailScreen extends StatefulWidget {
  final ArticleModel article;
  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isFavorite = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final fav = await _firestoreService.isFavorite(uid, widget.article.id);
    if (!mounted) return;
    setState(() {
      _isFavorite = fav;
      _isChecking = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isFavorite = !_isFavorite);

    if (_isFavorite) {
      await _firestoreService.addFavorite(
        uid: uid,
        articleId: widget.article.id,
        title: widget.article.title,
        imageUrl: widget.article.imageUrl,
        newsSite: widget.article.newsSite,
      );
    } else {
      await _firestoreService.removeFavorite(uid, widget.article.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    return Scaffold(
      // AppBar otomatis menampilkan tombol Back karena halaman ini di-push
      appBar: AppBar(
        actions: [
          if (!_isChecking)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article.imageUrl,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 240, color: Colors.grey[300]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Chip(label: Text(article.newsSite)),
                  const SizedBox(height: 16),
                  Text(
                    article.summary,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
