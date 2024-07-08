import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'auth.dart';

class PublicImage extends StatefulWidget {
  final String imageUrl;
  final String placeholderPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  PublicImage({
    required this.imageUrl,
    required this.placeholderPath,
    this.width,
    this.height,
    required this.fit,
  });

  @override
  _PublicImageState createState() => _PublicImageState();
}

class _PublicImageState extends State<PublicImage> {
  late Future<Uint8List> _imageData;
  Future<Uint8List> _fetchImage() async {
    final token = await readAccess();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse(widget.imageUrl),
      headers: {
        'access': '$token',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  @override
  void initState() {
    super.initState();
    _imageData = _fetchImage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Image.asset(
            widget.placeholderPath,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          );
        } else if (snapshot.hasError) {
          return Icon(Icons.error); // 오류 발생 시 표시할 아이콘
        } else {
          return Image.memory(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          );
        }
      },
    );
  }
}