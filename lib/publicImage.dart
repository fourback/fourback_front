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
  final bool isCircular;

  PublicImage({
    required this.imageUrl,
    required this.placeholderPath,
    this.width,
    this.height,
    required this.fit,
    this.isCircular = false,
    Key? key,
  }) : super(key: key);

  @override
  _PublicImageState createState() => _PublicImageState();
}

class _PublicImageState extends State<PublicImage> {
  late Future<Uint8List> _imageData;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  @override
  void didUpdateWidget(PublicImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      _fetchImage(); // 이미지 URL이 변경될 때마다 이미지를 다시 가져옵니다.
    }
  }

  Future<void> _fetchImage() async {
    setState(() {
      _imageData = _loadImage();
    });
    return; // 이 부분이 추가되었습니다.
  }

  Future<Uint8List> _loadImage() async {
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
    } else if (response.statusCode == 401) {
      bool success = await reissueToken(context);
      if (success) {
        return await _loadImage();
      } else {
        print('토큰 재발급 실패');
        throw Exception('Failed to load image');
      }
    } else {
      throw Exception('Failed to load image');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = FutureBuilder<Uint8List>(
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
    if (widget.isCircular) {
      return ClipOval(child: imageWidget);
    } else {
      return imageWidget;
    }
  }
}