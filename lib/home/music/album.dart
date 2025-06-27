import 'package:flutter/material.dart';

class Album extends StatefulWidget {
  const Album({super.key});

  @override
  State<Album> createState() => _AlbumState();
}

class _AlbumState extends State<Album> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return const Placeholder();
  }
}
